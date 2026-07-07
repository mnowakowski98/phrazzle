import 'player.dart';
import 'package:uuid/uuid.dart';

class Game {
  static const gameStartedMessage = 'Game already started';

  final _players = <String, Player>{};
  Map<String, Player> get players => Map.unmodifiable(_players);

  var _isStarted = false;
  get isStarted => _isStarted;

  /// Add a player to the game and get id
  String addPlayer(String name) {
    if (isStarted) throw StateError(gameStartedMessage);

    final id = Uuid().v4();
    _players[id] = Player(name);
    return id;
  }

  /// Remove a player by id
  Player? removePlayer(String id) {
    if (isStarted) throw StateError(gameStartedMessage);

    return _players.remove(id);
  }

  /// Start the game, prevent player map modification
  bool start() {
    if (isStarted) throw StateError(gameStartedMessage);
    if (_players.isEmpty) return false;

    _isStarted = true;
    return true;
  }

  /// End the game and get winning player ids
  List<String> end() {
    if (isStarted == false) throw StateError('Game not started yet');

    final max = _players.values.fold(0, (final currentMax, final value) {
      if (value.score > currentMax) return value.score;
      return currentMax;
    });
    final winners = _players.entries.where(
      (final player) => player.value.score == max,
    );
    return List<String>.from(winners.map((final winner) => winner.key));
  }
}
