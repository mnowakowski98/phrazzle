import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'phrazzle_central.g.dart';

Game game = Game();
Round? round;

Map<String, WebSocketChannel> channels = {};

/// Service for the creation, cordination and status of games
class PhrazzleCentral {
  // TODO: Remove
  /// Game/Round output for testing
  @Route.get('/game')
  Response getInfo(Request _) {
    return Response.ok(
      jsonEncode({
        'game': game.toJson(),
        'round': round != null ? round?.toJson() : 'No Round',
      }), headers: {'content-type': 'application/json'}
    );
  }

  /// Reset the game, close active connections
  @Route.post('/game')
  Response createGame(Request _) {
    game = Game();
    round = null;
    for (final channel in channels.values) {
      channel.sink.close();
    }
    channels = {};
    print('Started new game');
    return Response.ok(null);
  }

  /// Join the game as an existing player
  @Route.get('/game/<playerId>')
  FutureOr<Response> joinGame(Request req, String playerId) {
    if (channels[playerId] != null) return Response.badRequest();
    return webSocketHandler((channel, _) {
      channels[playerId] = channel;

      // Unlink active channel from player (does not delete player)
      channel.sink.done.whenComplete(() {
        channels.remove(playerId);
        print('Player: $playerId left');
      });

      // Send current game state and sync with updates
      channel.sink.add(jsonEncode(game.toJson()));
      game.stateStream.listen((data) => channel.sink.add(jsonEncode(data)));

      // Send/sync round if exists
      if (round != null) {
        channel.sink.add(jsonEncode(round!.toJson()));
        round!.getUpdateStream().listen(
          (data) => channel.sink.add(jsonEncode(data)),
        );
      }

      print('Player: $playerId joined');
    })(req);
  }

  /// Create a player with a given name
  @Route.post('/game/<playerName>')
  Response addPlayer(Request _, String playerName) {
    final playerId = game.addPlayer(Uri.decodeComponent(playerName));
    print('Added player: $playerId - $playerName');
    return Response.ok(playerId);
  }

  /// Remove an existing player by id
  @Route.delete('/game/<playerId>')
  Response removePlayer(Request _, String playerId) {
    game.removePlayer(playerId);
    return Response.ok(null);
  }

  /// Start the game
  @Route.put('/game/<phrase>')
  Response startGame(Request _, String phrase) {
    final started = game.start();
    if (started) {
      round = Round(Uri.decodeComponent(phrase), game.players.keys.toList());

      for (final channel in channels.values) {
        channel.sink.add(jsonEncode(round!.toJson()));
        round!.getUpdateStream().listen(
          (data) => channel.sink.add(jsonEncode(data)),
        );
      }
    }

    print('Started game');
    return Response.ok('$started');
  }

  /// Add player sub phrase
  @Route.post('/game/phrase/<playerId>/<phrase>')
  Response addSubPhrase(
    Request _,
    String playerId,
    String phrase,
  ) {
    final decodedPhrase = Uri.decodeComponent(phrase);
    round?.addPlayerSubPhrase(playerId, decodedPhrase);

    print(
      'Added player phrase: $decodedPhrase to ${game.players[playerId]?.name}',
    );
    return Response.ok(null);
  }

  /// End the game
  @Route.delete('/game')
  Response endGame(Request _) {
    if (game.isStarted == false) return Response.ok(false);

    final scores = round!.scoreRound();
    game.incrementScores(scores);
    game.end();

    print('Ended game');
    return Response.ok(null);
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
