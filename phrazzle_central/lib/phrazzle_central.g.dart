// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrazzle_central.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PhrazzleCentralRouter(PhrazzleCentral service) {
  final router = Router();
  router.add('GET', r'/game/', service.getGameInformation);
  router.add('POST', r'/game/', service.createGame);
  router.add('PUT', r'/game/set/<phrase>', service.setGamePhrase);
  router.add('POST', r'/game/join/<player>', service.joinGame);
  router.add('PUT', r'/game/start/<gameId>', service.startGame);
  return router;
}
