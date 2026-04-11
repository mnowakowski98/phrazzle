import 'package:uuid/uuid.dart';

class Phrazzle {
  final _scores = <String, int>{};

  String addPlayer() {
    final id = Uuid().toString();
    _scores[id] = 0;
    return id;
  }

  int? removePlayer(String id) => _scores.remove(id);

  int? getScore(String id) => _scores[id];

  int incrementScore(String id, int amount) {
    final currentScore = _scores[id];
    if (currentScore == null) {
      throw RangeError('Incremented score that does not exist');
    }
    _scores[id] = currentScore + amount;
    return _scores[id]!;
  }

  bool start() {
    if (_scores.isEmpty) return false;
    return true;
  }

  List<String> end() {
    final max = _scores.values.fold(0, (final currentMax, final value) {
      if (value > currentMax) return value;
      return currentMax;
    });
    final winners = _scores.entries.where((final score) => score.value == max);
    return List.from(winners.map((final winner) => winner.key));
  }

  static bool isValidSubPhrase(
    String rootPhrase,
    String subPhrase, [
    bool isFirstRecurse = true,
  ]) {
    // Check if the sub phrase contains an uninterrupted subset from the root phrase
    if (isFirstRecurse == true) {
      final wordsInRootPhrase = rootPhrase.split(' ');
      final wordsInSubPhrase = subPhrase.split(' ');

      if (wordsInSubPhrase.any(
        (final string) => wordsInRootPhrase.contains(string),
      )) {
        return false;
      }
    }

    final currentChar = subPhrase[0];

    // Check if current processing char is in the root phrase
    if (rootPhrase.contains(currentChar) == false) return false;

    // No more chars to check, sub phrase is valid
    if (subPhrase.length == 1) return true;

    // Check next char with truncated phrases
    return isValidSubPhrase(
      rootPhrase.substring(rootPhrase.indexOf(currentChar)),
      subPhrase.substring(1),
      false,
    );
  }

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
}
