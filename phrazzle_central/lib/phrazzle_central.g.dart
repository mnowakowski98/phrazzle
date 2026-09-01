// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrazzle_central.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PhrazzleCentralRouter(PhrazzleCentral service) {
  final router = Router();
  router.add('POST', r'/game', service.createGame);
  router.add('GET', r'/game/<playerName>', service.joinGame);
  router.add('PUT', r'/game/<phrase>', service.startGame);
  router.add('POST', r'/game/phrase/<playerId>/<phrase>', service.addSubPhrase);
  router.add('DELETE', r'/game', service.endGame);
  return router;
}
