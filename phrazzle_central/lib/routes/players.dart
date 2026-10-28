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
  Response getUser(Request _, String playerId) {
    final userId = playerStore.getUserId(playerId);
    if (userId == null) return Response.notFound(playerId);
    final user = userStore.getUser(userId);
    if (user == null) throw StateError('player $playerId linked to invalid user $userId');
    return Response.ok(user.jsonString);
  }

  Router get router => _$PlayersRouter(this);
}
