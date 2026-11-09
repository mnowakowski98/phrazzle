// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'players.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$PlayersRouter(Players service) {
  final router = Router();
  router.add('GET', r'/player/<playerId>/user', service.getUser);
  router.add('GET', r'/player/user/<userId>/active', service.getActiveRecords);
  return router;
}
