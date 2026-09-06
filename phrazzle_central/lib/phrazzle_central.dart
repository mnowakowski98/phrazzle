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
  /// Reset the game
  @Route.post('/game')
  Future<Response> createGame(Request _) async {
    game = Game();
    print('Started new game');
    return Response.ok(null);
  }

  /// Join the game as an existing player
  @Route.get('/game/<playerId>')
  FutureOr<Response> joinGame(Request req, String playerId) =>
      webSocketHandler((channel, _) {
        channels[playerId] = channel;

        channel.sink.done.whenComplete(() {
          channels.remove(playerId);
          // game.removePlayer(playerId);
          print('Player: $playerId left');
        });

        channel.sink.add(jsonEncode(game.toJson()));
        game.getJsonUpdateStream().listen(
          (data) => channel.sink.add(jsonEncode(data)),
        );

        if (round != null) {
          channel.sink.add(jsonEncode(round!.toJson()));
          round!.getUpdateStream().listen(
            (data) => channel.sink.add(jsonEncode(data)),
          );
        }

        print('Player: $playerId joined');
      })(req);

  /// Create a player with a given name
  @Route.post('/game/<playerName>')
  Future<Response> addPlayer(Request _, String playerName) async {
    final playerId = game.addPlayer(playerName);
    print('Added player: $playerId - $playerName');
    return Response.ok(playerId);
  }

  /// Start the game
  @Route.put('/game/<phrase>')
  Future<Response> startGame(Request _, String phrase) async {
    final started = game.start();
    if (started) {
      round = Round(phrase, game.players.keys.toList());

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
  Future<Response> addSubPhrase(
    Request _,
    String playerId,
    String phrase,
  ) async {
    round?.addPlayerSubPhrase(playerId, phrase);

    print('Added player phrase: $phrase to ${game.players[playerId]?.name}');
    return Response.ok(null);
  }

  /// End the game
  @Route.delete('/game')
  Future<Response> endGame(Request _) async {
    if (game.isStarted == false) return Response.ok(false);

    final scores = round!.scoreRound();
    game.incrementScores(scores);
    game.end();

    print('Ended game');
    return Response.ok(null);
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
