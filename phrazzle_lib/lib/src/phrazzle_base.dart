abstract class PhrazzleBase {
  /// Determines if a sub phrase is valid from a given root phrase
  static bool isValidSubPhrase(String rootPhrase, String subPhrase) {
    // Check if the sub phrase contains an uninterrupted word or phrase from the root phrase
    final wordsInRootPhrase = rootPhrase.split(' ');
    final wordsInSubPhrase = subPhrase.split(' ');

    if (wordsInSubPhrase.any(
      (final string) => wordsInRootPhrase.contains(string),
    )) {
      return false;
    }

    // Prep phrases
    final rootPhraseTransform = rootPhrase.trim().toLowerCase().replaceAll(' ', '');
    final subPhraseTransform = subPhrase.trim().toLowerCase().replaceAll(' ', '');

    if (subPhraseTransform.isEmpty) return false;

    var isValid = true;
    var rootProcessingIndex = 0;
    for (var index = 0; index < subPhraseTransform.length; index++) {
      final subRoot = rootPhraseTransform.substring(rootProcessingIndex);
      final matchedCharIndex = subRoot.indexOf(subPhraseTransform[index]);
      if (matchedCharIndex >= 0) {
        rootProcessingIndex = matchedCharIndex + 1;
      } else {
        isValid = false;
      }
    }
    return isValid;
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
