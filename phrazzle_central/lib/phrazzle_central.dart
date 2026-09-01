import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';

part 'phrazzle_central.g.dart';

Game game = Game();
Round? round;

/// Service for the creation, cordination and status of games
class PhrazzleCentral {
  @Route.get('/game')
  Future<Response> getGameInfo(Request _) async {
    return Response.ok(game.export().toJson().toString());
  }

  @Route.get('/round')
  Future<Response> getRoundInfo(Request _) async {
    return Response.ok(round?.export().toJson().toString());
  }

  /// Reset the game
  @Route.post('/game')
  Future<Response> createGame(Request _) async {
    game = Game();
    print('Started new game');
    return Response.ok(null);
  }

  /// Join the game with a given player name
  @Route.post('/game/<playerName>')
  Future<Response> joinGame(Request _, String playerName) async {
    final playerId = game.addPlayer(playerName);
    print('Added player: $playerName');
    return Response.ok(playerId);
  }

  // Start the game
  @Route.put('/game/<phrase>')
  Future<Response> startGame(Request _, String phrase) async {
    final started = game.start();
    if (started) round = Round(phrase, game.players.keys.toList());

    print('Started game');
    return Response.ok('$started');
  }

  // Add player sub phrase
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

  // End the game
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
