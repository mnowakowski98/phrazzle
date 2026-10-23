// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'games.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$GamesRouter(Games service) {
  final router = Router();
  router.add('GET', r'/game/<gameCode>', service.getGameId);
  router.add('GET', r'/game/code/<gameId>', service.getGameCode);
  router.add('POST', r'/game', service.createGame);
  router.add('POST', r'/game/<gameId>/<playerName>', service.addPlayer);
  router.add('GET', r'/game/<gameId>/<playerId>', service.joinGame);
  router.add('DELETE', r'/game/<gameId>/<playerId>', service.removePlayer);
  router.add('PUT', r'/game/<gameId>/<phrase>', service.startGame);
  router.add(
    'POST',
    r'/game/phrase/<gameId>/<playerId>/<phrase>',
    service.addSubPhrase,
  );
  router.add('PUT', r'/game/<gameId>/<playerId>/done', service.endEntry);
  return router;
}
