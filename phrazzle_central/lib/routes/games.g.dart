// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'games.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$GamesRouter(Games service) {
  final router = Router();
  router.add('GET', r'/game/<gameCode>', service.getGameId);
  router.add('GET', r'/game/<gameId>/code', service.getGameCode);
  router.add('POST', r'/game', service.createGame);
  router.add('POST', r'/game/<gameId>/player/<userId>', service.addPlayer);
  router.add('GET', r'/game/<gameId>/player/<playerId>', service.joinGame);
  router.add(
    'DELETE',
    r'/game/<gameId>/player/<playerId>',
    service.removePlayer,
  );
  router.add('POST', r'/game/<gameId>/start', service.startGame);
  router.add('POST', r'/game/<gameId>/round/<phrase>', service.createRound);
  router.add('PUT', r'/game/<gameId>/round/<roundId>', service.setCurrentRound);
  router.add(
    'POST',
    r'/game/<gameId>/player/<playerId>/phrase/<phrase>',
    service.addSubPhrase,
  );
  router.add('PUT', r'/game/<gameId>/player/<playerId>/lock', service.endEntry);
  return router;
}
