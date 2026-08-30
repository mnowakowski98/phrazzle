import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';

part 'phrazzle_central.g.dart';

Game game = Game();
Round? round;

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
  Future<Response> joinGame(Request _, String playerName) async {
    final playerId = game.addPlayer(playerName);
    print('Added player: $playerName');
    return Response.ok(playerId);
  }

  // Start the game
  @Route.put('/game/<phrase>')
  Future<Response> startGame(Request _, String phrase) async {
    if (game.isStarted) {
      round?.scoreRound();
      final winnerIds = game.end();
      final winningPlayers = game.players.entries.where(
        (final playerEntry) => winnerIds.contains(playerEntry.key),
      );

      print('Ended game');
      return Response.ok(winningPlayers.toString());
    }

    final started = game.start();
    if (started) round = Round(phrase, game.players.values.toList());

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
    final player = game.players[playerId];
    round?.addPlayerSubPhrase(player!, phrase);

    print('Added player phrase: $phrase to ${player?.name}');
    return Response.ok(null);
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
