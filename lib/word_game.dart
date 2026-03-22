class WordGame {
  bool isValidSubPhrase(
    String rootPhrase,
    String subPhrase, [
    bool isFirstRecurse = true,
  ]) {
    // Check if the sub phrase contains a whole word from the root phrase
    // TODO: Current implementation probably will have false positives - check this when less stupid
    if (isFirstRecurse == true && rootPhrase.contains(subPhrase)) return false;

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
