class Round {
  final String phrase;
  final List<int> playerScores;
  final List<List<String>> playerPhrases;

  Round._internal(this.phrase, this.playerScores, this.playerPhrases);

  factory Round(String phrase, int numPlayers) {
    final playerScores = List.filled(numPlayers, 0);
    final playerPhrases = List.generate(
      numPlayers,
      (_) => List<String>.empty(growable: true),
    );

    return Round._internal(phrase, playerScores, playerPhrases);
  }

  void addPlayerPhrase(int playerIndex, String phrase) {
    final phraseList = playerPhrases.elementAt(playerIndex);
    phraseList.add(phrase);
  }
}
