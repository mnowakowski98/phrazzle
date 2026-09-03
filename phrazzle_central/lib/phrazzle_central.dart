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

  /// Join the game with a given player name
  @Route.post('/game/<playerName>')
  Future<Response> joinGame(Request req, String playerName) async {
    final socketHandlerResponse = webSocketHandler((websocket, _) async {
      final playerId = game.addPlayer(playerName);
      channels[playerId] = websocket;
      websocket.sink.add(playerId);

      websocket.sink.add(game.toJson().toString());
      game.getJsonUpdateStream().listen(
        (data) => websocket.sink.add(data.toString()),
      );

      if (round != null) {
        websocket.sink.add(round!.toJson().toString());
        round!.getUpdateStream().listen(
          (data) => websocket.sink.add(data.toString()),
        );
      }

      print('Added player: $playerName');
    })(req);

    return socketHandlerResponse;
  }

  /// Start the game
  @Route.put('/game/<phrase>')
  Future<Response> startGame(Request _, String phrase) async {
    final started = game.start();
    if (started) {
      round = Round(phrase, game.players.keys.toList());

      for (final channel in channels.values) {
        round!.getUpdateStream().listen((data) => channel.sink.add(data));
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
    final winnerIds = game.end();

    print('Ended game');
    return Response.ok(winnerIds);
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
