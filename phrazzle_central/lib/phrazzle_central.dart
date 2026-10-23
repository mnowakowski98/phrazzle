import 'dart:async';
import 'dart:convert';

import 'package:phrazzle_central/game_store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'phrazzle_central.g.dart';

class Client {
  final WebSocketChannel channel;
  final String deviceId;
  final String instanceId;

  Client(this.channel, this.deviceId, this.instanceId);
  factory Client.pending(WebSocketChannel channel) => Client(channel, '', '');
}

final clients = <String, Client>{};

/// Service for the creation, cordination and status of games
class PhrazzleCentral {
  final GameStore gameStore;

  PhrazzleCentral(this.gameStore);

  /// Get the game id from a game code
  @Route.get('/game/<gameCode>')
  Response getGameId(Request _, String gameCode) {
    gameCode = gameCode.toLowerCase();
    final codeIds = <String, String>{};
    codeIds.addEntries(gameStore.gameIds.map((id) => MapEntry(id.substring(0, 5), id)));
    final gameId = codeIds[gameCode];
    if (gameId == null) return Response.notFound(gameCode);
    return Response.ok(gameId);
  }

  // Get the game code from a game id
  @Route.get('/game/code/<gameId>')
  Response getGameCode(Request _, String gameId) {
    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);
    return Response.ok(gameId.substring(0, 5));
  }

  /// Create a new game
  @Route.post('/game')
  Response createGame(Request _) {
    final gameId = gameStore.createGame(Game());

    print('Created game $gameId');
    return Response.ok(gameId);
  }

  /// Create a new player in an existing game
  @Route.post('/game/<gameId>/<playerName>')
  Response addPlayer(Request _, String gameId, String playerName) {
    final decodedName = Uri.decodeComponent(playerName);
    final game = gameStore.getGame(gameId);
    if (game == null) {
      return Response.notFound(gameId);
    }

    final playerId = game.addPlayer(decodedName);

    print('Created player $decodedName ($playerId) in $gameId');
    return Response.ok(playerId);
  }

  /// Join the game as an existing player
  @Route.get('/game/<gameId>/<playerId>')
  FutureOr<Response> joinGame(Request req, String gameId, String playerId) {
    final game = gameStore.getGame(gameId);
    if (game == null) {
      return Response.notFound(gameId);
    }

    final player = game.players[playerId];
    if (player == null) return Response.notFound(playerId);
    if (clients[playerId] != null) {
      print('$playerId already connected');
      return Response.badRequest(
        body: jsonEncode({'playerId': playerId, 'message': 'Player already connected'}),
        headers: {'content-type': 'application/json'},
      );
    }

    // Upgrade the connection to a websocket
    return webSocketHandler((channel, _) {
      clients[playerId] = Client.pending(channel);

      // Get device and instance id from the client
      channel.stream.listen((data) {
        final decoded = jsonDecode(data) as Map<String, dynamic>;
        final deviceId = decoded['deviceId'];
        final instanceId = decoded['instanceId'];
        if (deviceId == null || instanceId == null) throw Exception('Received invalid message trying to connect ${player.name}');
        clients[playerId] = Client(channel, deviceId, instanceId);
        print('Got client ids for ${player.name}: $deviceId - $instanceId');
      });

      // Unlink active channel from player (does not delete player)
      channel.sink.done.whenComplete(() {
        clients.remove(playerId);
        print('${player.name} left game $gameId');
      });

      // Send current game state and sync with updates
      channel.sink.add(jsonEncode(game.toJson()));
      game.jsonStringStream.listen(
        // Get the channel from the map again in case it's been removed
        // Otherwise would call add on a closed sink
        (data) => clients[playerId]?.channel.sink.add(data),
      );

      final round = gameStore.getRounds(gameId)?.first;
      // Send/sync round if exists
      if (round != null) {
        channel.sink.add(jsonEncode(round.toJson()));
        round.jsonStringStream.listen(
          // Same reason as above
          (data) => clients[playerId]?.channel.sink.add(data),
        );
      }

      print('${player.name} joined game $gameId (pending)');
    })(req);
  }

  /// Remove an existing player by id
  @Route.delete('/game/<gameId>/<playerId>')
  Response removePlayer(Request _, String gameId, String playerId) {
    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);

    final player = game.players[playerId];
    if (player == null) return Response.notFound(playerId);

    // Close channel if it's still active
    final client = clients[playerId];
    client?.channel.sink.close(1000);
    clients.remove(playerId);

    game.removePlayer(playerId);

    if (game.players.isEmpty) {
      gameStore.removeGame(gameId);
      print('Removed $gameId due to lack of players');
    }

    print('Removed ${player.name} from $gameId');
    return Response.ok(playerId);
  }

  /// Start the game
  @Route.put('/game/<gameId>/<phrase>')
  Response startGame(Request _, String gameId, String phrase) {
    final decodedPhrase = Uri.decodeComponent(phrase);

    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);

    final started = game.start();
    if (started == false) {
      print('$gameId already started');
      return Response.badRequest(
        body: jsonEncode({'gameId': gameId, 'message': 'Game already started'}),
        headers: {'content-type': 'application/json'},
      );
    }


    // Create the round
    final round = Round(
      decodedPhrase,
      game.players.keys.toList(),
    );

    final roundId = gameStore.createRound(gameId, round);

    // Notify clients and subscribe to round updates
    for (final playerId in game.playerIds) {
      final client = clients[playerId];
      client?.channel.sink.add(jsonEncode(round.toJson()));
      round.jsonStringStream.listen(
        (data) => client?.channel.sink.add(data),
      );
    }

    print('Started $gameId : $roundId with phrase "$decodedPhrase"');
    return Response.ok(gameId);
  }

  /// Add player phrase
  @Route.post('/game/phrase/<gameId>/<playerId>/<phrase>')
  Response addSubPhrase(Request _, String gameId, String playerId, String phrase) {
    final decodedPhrase = Uri.decodeComponent(phrase);

    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);
    if (game.isStarted == false) {
      return Response.badRequest(
        body: jsonEncode({'gameId': gameId, 'message': 'Game not started yet'}),
        headers: {'content-type': 'application/json'}
      );
    }

    final player = game.players[playerId];
    if (player == null) return Response.notFound(gameId);
    
    final rounds = gameStore.getRounds(gameId);
    final round = rounds?.first;
    if (round == null) throw Exception('$gameId is started but has no round');

    if (round.phraseLocks[playerId] == true) {
      print('$playerId has already locked in');
      return Response.badRequest(
        body: jsonEncode({'playerId': 'Player has already locked in'}),
        headers: {'content-type': 'application/json'}
      );
    }

    final existingPhrases = round.phrases[playerId]!;
    final rootPhrase = existingPhrases.isNotEmpty ? existingPhrases.last : round.initialPhrase;
    final matchInfo = PhrazzleBase.getPhraseMatchingInformation(rootPhrase, decodedPhrase);
    if (matchInfo.isValid == true) {
      round.addPlayerSubPhrase(playerId, decodedPhrase);
    } else {
      print('$decodedPhrase failed validation');
      return Response.badRequest(
        body: jsonEncode({'phrase': decodedPhrase, 'message': 'Phrase failed validation'}),
        headers: {'content-type': 'application/json'},
      );
    }

    print('Added phrase "$decodedPhrase" to ${player.name} in $gameId');
    return Response.ok(jsonEncode(matchInfo.toJson()));
  }

  /// Prevent player from entering more phrases
  /// End the game if all players are done
  @Route.put('/game/<gameId>/<playerId>/done')
  Response endEntry(Request _, String gameId, String playerId) {
    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);

    final round = gameStore.getRounds(gameId)?.first;
    if (round == null) {
      print('$gameId isn\'t started yet');
      return Response.badRequest(
        body: jsonEncode({'gameId': gameId, 'message': 'Game isn\'t started yet'}),
        headers: {'content-type': 'application/json'}
      );
    }

    final player = game.players[playerId];
    if (player == null) return Response.notFound(playerId);

    round.lockPhrases(playerId);

    if (round.phraseLocks.values.every((isLocked) => isLocked == true)) {
      final scores = round.scoreRound();
      game.incrementScores(scores);
      game.end();

      // Close leftover connections after a bit
      Timer(const Duration(minutes: 5), () {
        for (final playerId in game.playerIds) {
          final client = clients[playerId];
          client?.channel.sink.close(1000);
        }
        gameStore.removeGame(gameId);
      });

      print('$gameId ended');
    }

    print('${player.name} finished entering phrases');
    return Response.ok(playerId);
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
