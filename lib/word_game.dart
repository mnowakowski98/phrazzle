class WordGame {
  bool isValidSubPhrase(
    String rootPhrase,
    String subPhrase, [
    bool isFirstRecurse = true,
  ]) {
    // Check if the sub phrase contains an uninterrupted subset from the root phrase
    if (isFirstRecurse == true) {
      final wordsInRootPhrase = rootPhrase.split(' ');
      final wordsInSubPhrase = subPhrase.split(' ');
      if (wordsInRootPhrase.contains(subPhrase)) return false;

      for (
        int subPhraseIndex = 0;
        subPhraseIndex == subPhrase.length;
        subPhraseIndex++
      ) {}
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
}
