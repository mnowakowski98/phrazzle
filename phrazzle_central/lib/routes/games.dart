import 'dart:async';
import 'dart:convert';

import 'package:phrazzle_central/stores/game_store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'games.g.dart';

class Client {
  final WebSocketChannel channel;
  final String deviceId;
  final String instanceId;

  Client(this.channel, this.deviceId, this.instanceId);
  factory Client.pending(WebSocketChannel channel) => Client(channel, '', '');
}

final clients = <String, Client>{};

/// Service for the creation, cordination and status of games
class Games {
  final GameStore gameStore;

  Games(this.gameStore);

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
  @Route.get('/game/<gameId>/code')
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
  @Route.post('/game/<gameId>/player')
  Response addPlayer(Request _, String gameId) {
    final game = gameStore.getGame(gameId);
    if (game == null) {
      return Response.notFound(gameId);
    }

    final playerId = game.addPlayer();

    print('Created player $playerId in $gameId');
    return Response.ok(playerId);
  }

  /// Join the game as an existing player
  @Route.get('/game/<gameId>/player/<playerId>')
  FutureOr<Response> joinGame(Request req, String gameId, String playerId) {
    final game = gameStore.getGame(gameId);
    if (game == null) {
      return Response.notFound(gameId);
    }

    if (game.players.contains(playerId) == false) return Response.notFound(playerId);
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
        if (deviceId == null || instanceId == null) throw Exception('Received invalid message trying to connect $playerId');
        clients[playerId] = Client(channel, deviceId, instanceId);
        print('Got client ids for $playerId: $deviceId - $instanceId');
      });

      // Send current game state and pipe future updates
      channel.sink.add(game.jsonString);
      game.jsonStringStream.listen((data) => channel.sink.add(data));

      // Unlink active channel from player (does not delete player)
      channel.sink.done.whenComplete(() {
        clients.remove(playerId);
        print('$playerId left game $gameId');
      });

      print('$playerId joined game $gameId (pending)');
    })(req);
  }

  /// Remove an existing player by id
  @Route.delete('/game/<gameId>/player/<playerId>')
  Response removePlayer(Request _, String gameId, String playerId) {
    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);

    if (game.players.contains(playerId) == false) return Response.notFound(playerId);

    // Close channel if it's still active
    final client = clients[playerId];
    client?.channel.sink.close(1000);
    clients.remove(playerId);

    game.removePlayer(playerId);

    if (game.players.isEmpty) {
      gameStore.removeGame(gameId);
      print('Removed $gameId due to lack of players');
    }

    print('Removed $playerId from $gameId');
    return Response.ok(playerId);
  }

  /// Start the game
  @Route.post('/game/<gameId>/start/<phrase>')
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

    print('Started $gameId with phrase "$decodedPhrase"');
    return Response.ok(gameId);
  }

  /// Add player phrase
  @Route.post('/game/phrase/<gameId>/player/<playerId>/phrase/<phrase>')
  Response addSubPhrase(Request _, String gameId, String playerId, String phrase) {
    phrase = Uri.decodeComponent(phrase);

    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);
    if (game.isStarted == false) {
      return Response.badRequest(
        body: jsonEncode({'gameId': gameId, 'message': 'Game not started yet'}),
        headers: {'content-type': 'application/json'}
      );
    }

    if (game.players.contains(playerId) == false) return Response.notFound(playerId);

    game.addPhrase(playerId, phrase);
    return Response.ok(phrase);
  }

  /// Prevent player from entering more phrases
  /// End the game if all players are done
  @Route.put('/game/<gameId>/players/<playerId>/done')
  Response endEntry(Request _, String gameId, String playerId) {
    final game = gameStore.getGame(gameId);
    if (game == null) return Response.notFound(gameId);

    if (game.players.contains(playerId) == false) return Response.notFound(playerId);

    final currentRound = game.currentRound;
    if (currentRound == null) {
      return Response.badRequest(
        body: jsonEncode({'gameId': gameId, 'message': 'Game has no current round'}),
        headers: {'content-type': 'application/json'}
      );
    }

    currentRound.phraseGroups[playerId]!.lock();

    // TODO: End game if all players are locked

    return Response.ok(playerId);
  }

  Router get router => _$GamesRouter(this);
}
