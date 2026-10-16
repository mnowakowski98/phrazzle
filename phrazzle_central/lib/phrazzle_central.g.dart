// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrazzle_central.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PhrazzleCentralRouter(PhrazzleCentral service) {
  final router = Router();
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
  router.add('DELETE', r'/game/<gameId>', service.endGame);
  return router;
}
