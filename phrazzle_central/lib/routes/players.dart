import 'dart:convert';

import 'package:phrazzle_central/stores/game_store.dart';
import 'package:phrazzle_central/stores/player_store.dart';
import 'package:phrazzle_central/stores/user_store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'players.g.dart';

/// Service for the creation, cordination and status of games
class Players {
  final GameStore gameStore;
  final PlayerStore playerStore;
  final UserStore userStore;

  Players(this.gameStore, this.playerStore, this.userStore);

  @Route.get('/player/<playerId>/user')
  Future<Response> getUser(Request _, String playerId) async {
    final userRecord = await playerStore.getPlayerRecord(playerId);
    if (userRecord == null) return Response.notFound(playerId);
    final userId = userRecord.userId;
    final user = await userStore.getUser(userId);
    if (user == null) throw StateError('player $playerId linked to invalid user $userId');
    return Response.ok(user.jsonString);
  }

  @Route.get('/player/user/<userId>/game/active')
  Future<Response> getActiveGames(Request _, String userId) async {
    final playerRecords = await playerStore.getUserRecords(userId);
    if (playerRecords.isEmpty) return Response.notFound(userId);

    final activeGameIds = <String>[];
    for (final record in playerRecords) {
      final game = await gameStore.getGame(record.gameId);
      if (game == null || game.info.isEnded) continue;
      activeGameIds.add(record.gameId);
    }

    return Response.ok(
      jsonEncode(activeGameIds),
      headers: {'content-type': 'application/json'},
    );
  } 

  Router get router => _$PlayersRouter(this);
}
