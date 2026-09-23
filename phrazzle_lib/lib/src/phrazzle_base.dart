abstract class PhrazzleBase {
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
  static int getNumberOfValidPhrases(String phrase, List<String> subPhrases) {
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
