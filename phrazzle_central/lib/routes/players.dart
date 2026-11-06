import 'package:phrazzle_central/stores/player_store.dart';
import 'package:phrazzle_central/stores/user_store.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'players.g.dart';

/// Service for the creation, cordination and status of games
class Players {
  final PlayerStore playerStore;
  final UserStore userStore;

  Players(this.playerStore, this.userStore);

  @Route.get('/player/<playerId>/user')
  Future<Response> getUser(Request _, String playerId) async {
    final userRecord = await playerStore.getPlayerRecord(playerId);
    if (userRecord == null) return Response.notFound(playerId);
    final userId = userRecord.$3;
    final user = await userStore.getUser(userId);
    if (user == null) throw StateError('player $playerId linked to invalid user $userId');
    return Response.ok(user.jsonString);
  }

  Router get router => _$PlayersRouter(this);
}
