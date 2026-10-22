import 'package:phrazzle_central/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

/// Game store that forgets when the instance stops existing
class VolatileGameStore extends GameStore {
  final _games = <String, Game>{};
  final _rounds = <String, Round>{};
  final _gameRounds = <String, String>{};

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

  @override
  String createRound(String gameId, Round round) {
    final roundId = Uuid().v4();
    _rounds[roundId] = round;
    _gameRounds[gameId] = roundId;
    return roundId;
  }

  @override
  Round? getRound(String roundId) => _rounds[roundId];

  @override
  Iterable<Round>? getRounds(String gameId) {
    final roundIds = _gameRounds[gameId];
    if (roundIds == null) return null;
    return _rounds.entries.where((round) => roundIds.contains(round.key)).map((entry) => entry.value);
  }
}