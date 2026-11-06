import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

/// Game store that forgets when the instance stops existing
class GameStore {
  final _games = <String, Game>{};
  final _disabledGames = <String, Game>{};

  GameStore();

  Future<Iterable<String>> get gameIds async => _games.keys;

  Future<String> createGame(Game game) async {
    final gameId = Uuid().v4();
    _games[gameId] = game;
    return gameId;
  }

  Future<Game?> getGame(String gameId) async => _games[gameId];

  Future<void> disableGame(String gameId) async {
    final game = _games[gameId];
    if (game == null) throw ArgumentError('Game $gameId is not active');
    _disabledGames[gameId] = game;
    _games.remove(gameId);
  }

  Future<void> removeGame(String gameId) async => _games.remove(gameId);
}