import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

/// Game store that forgets when the instance stops existing
class GameStore {
  final _games = <String, Game>{};
  final _playerUsers = <String, String>{};

  GameStore();

  Iterable<String> get gameIds => _games.keys;

  String createGame(Game game) {
    final gameId = Uuid().v4();
    _games[gameId] = game;
    return gameId;
  }

  Game? getGame(String gameId) => _games[gameId];

  void removeGame(String gameId) => _games.remove(gameId);
}