import 'package:uuid/uuid.dart';

class PhrazzleBase {
  final _scores = <String, int>{};
  Map<String, int> get scores => Map.unmodifiable(_scores);

  var _started = false;
  bool get started => _started;

  /// Add a player to the game and get id
  String addPlayer() {
    if (started) throw StateError('Game already started');

    final id = Uuid().v4();
    _scores[id] = 0;
    return id;
  }

  /// Remove a player by id
  int? removePlayer(String id) {
    if (started) throw StateError('Game already started');

    return _scores.remove(id);
  }

  int? getScore(String id) => _scores[id];

  int incrementScore(String id, int amount) {
    if (started == false) throw StateError('Game not started yet');

    final currentScore = _scores[id];
    if (currentScore == null) {
      throw RangeError('Incremented score that does not exist');
    }
    _scores[id] = currentScore + amount;
    return _scores[id]!;
  }

  bool start() {
    if (started) throw StateError('Game already started');

    if (_scores.isEmpty) return false;
    _started = true;
    return true;
  }

  /// End the game and get winning player ids
  List<String> end() {
    if (started == false) throw StateError('Game not started yet');

    final max = _scores.values.fold(0, (final currentMax, final value) {
      if (value > currentMax) return value;
      return currentMax;
    });
    final winners = _scores.entries.where((final score) => score.value == max);
    return List<String>.from(winners.map((final winner) => winner.key));
  }

  /// Determines if a sub phrase is valid from a given root phrase
  static bool isValidSubPhrase(
    String rootPhrase,
    String subPhrase, [
    bool isFirstRecurse = true,
  ]) {
    // Check if the sub phrase contains an uninterrupted word or phrase from the root phrase
    if (isFirstRecurse == true) {
      final wordsInRootPhrase = rootPhrase.split(' ');
      final wordsInSubPhrase = subPhrase.split(' ');

      if (wordsInSubPhrase.any(
        (final string) => wordsInRootPhrase.contains(string),
      )) {
        return false;
      }
    }

    // Prep phrases
    final rootPhraseTransform = !isFirstRecurse
        ? rootPhrase
        : rootPhrase.trim().toLowerCase().replaceAll(' ', '');
    final subPhraseTransform = !isFirstRecurse
        ? subPhrase
        : subPhrase.trim().toLowerCase().replaceAll(' ', '');

    final currentChar = subPhraseTransform[0];

    // Check if current processing char is in the root phrase
    if (rootPhraseTransform.contains(currentChar) == false) return false;

    // No more chars to check, sub phrase is valid
    if (subPhraseTransform.length == 1) return true;

    // Check next char with truncated phrases
    return isValidSubPhrase(
      rootPhraseTransform.substring(rootPhraseTransform.indexOf(currentChar)),
      subPhraseTransform.substring(1),
      false,
    );
  }

  /// Scores a chain of sub phrases until invalid or done
  static int scorePhrases(String phrase, List<String> subPhrases) {
    var invalidSubPhrase = false;
    return subPhrases.fold(0, (final score, final subPhrase) {
      if (invalidSubPhrase) return score;
      final isValid = isValidSubPhrase(phrase, subPhrase);
      if (isValid == false) {
        invalidSubPhrase = true;
        return score;
      }
      return score + 1;
    });
  }

  /// Get a player's score
  int? getPlayerScore(String id) => _scores[id];

  /// Increment a player's score
  int incrementPlayerScore(String id, int amount) {
    if (_started == false) throw StateError('Game not started yet');

    final currentScore = _scores[id];
    if (currentScore == null) {
      throw RangeError('Incremented score that does not exist');
    }
    _scores[id] = currentScore + amount;
    return _scores[id]!;
  }
}
