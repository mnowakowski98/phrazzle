import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

/// Game store that forgets when the instance stops existing
class GameStore {
  final _games = <String, Game>{};

  GameStore();

  Future<Iterable<String>> get gameIds async => _games.keys;

  Future<String> createGame(Game game) async {
    final gameId = Uuid().v4();
    _games[gameId] = game;
    return gameId;
  }

  Future<Game?> getGame(String gameId) async => _games[gameId];

  Future<Map<String, Game?>> getGames(Set<String> gameIds) async => {for (final id in gameIds) id : _games[id]};

  Future<void> removeGame(String gameId) async => _games.remove(gameId);
}