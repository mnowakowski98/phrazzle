import 'player.dart';
import 'phrazzle_base.dart';

class Round {
  final String initialPhrase;
  final Map<Player, List<String>> _subPhrases;
  var _isScored = false;
  get isScored => _isScored;

  Round._internal(this.initialPhrase, this._subPhrases);

  /// Create sub phrase map from a list of players
  factory Round(String initialPhrase, List<Player> players) {
    return Round._internal(
      initialPhrase,
      Map.fromEntries(players.map((player) => MapEntry(player, <String>[]))),
    );
  }

  /// Add a sub phrase for a player
  void addPlayerSubPhrase(Player player, String subPhrase) {
    if (_isScored) throw Exception('Round has already been scored');
    _subPhrases[player]?.add(subPhrase);
  }

  /// Set player scores from their sub phrases
  void scoreRound() {
    if (isScored) throw Exception('Round has already been scored');
    for (final entry in _subPhrases.entries) {
      entry.key.score = PhrazzleBase.getNumberOfValidPhrases(
        initialPhrase,
        entry.value,
      );
    }
    _isScored = true;
  }
}
