import 'package:phrazzle_central/stores/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

/// Game store that forgets when the instance stops existing
class VolatileGameStore extends GameStore {
  final _games = <String, Game>{};

  VolatileGameStore();

  @override
  Iterable<String> get gameIds => _games.keys;

  @override
  String createGame(Game game) {
    final gameId = Uuid().v4();
    _games[gameId] = game;
    return gameId;
  }

  @override
  Game? getGame(String gameId) => _games[gameId];

  @override
  void removeGame(String gameId) => _games.remove(gameId);
}