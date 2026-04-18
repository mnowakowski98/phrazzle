import 'package:flutter/material.dart';
import 'package:phrazzle/player_entries.dart';
import 'package:phrazzle/player_list.dart';
import 'package:phrazzle/winners.dart';
import 'package:phrazzle_lib/phrazzle.dart';

enum _FormState { players, startingPhrase, entries, winners }

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  String inputValue = '';
  static const List<_FormState> formStates = [
    .players,
    .startingPhrase,
    .entries,
    .winners,
  ];
  int formStateIndex = 0;
  _FormState formState() => formStates[formStateIndex];

  final game = Phrazzle();

  int playerIndex = 0;
  final players = <Player>[];
  String rootPhrase = '';
  final playerPhraseEntries = <String>[];
  final winners = <Player>[];

  void commitText(String text) {
    setState(() {
      switch (formState()) {
        case .players:
          players.add(Player(game.addPlayer(), text, 0));
          break;
        case .startingPhrase:
          rootPhrase = text;
          break;
        case .entries:
          playerPhraseEntries.add(text);
          break;
        case .winners:
          break;
      }
    });
  }

  void nextPage() {
    setState(() {
      final isEntryForm = formState() == .entries;

      // Score entries if end of player entries
      if (isEntryForm) {
        final score = Phrazzle.scorePhrases(rootPhrase, playerPhraseEntries);
        final totalScore = game.incrementScore(players[playerIndex].id, score);
        players[playerIndex].score = totalScore;
      }

      final isEndOfPlayerEntries =
          isEntryForm && ++playerIndex >= players.length;

      final nextFormExists = formStateIndex + 1 < formStates.length;

      if ((isEntryForm == false || isEndOfPlayerEntries) && nextFormExists) {
        formStateIndex++;
      }

      if (formState() == .players) players.clear();
      if (formState() == .startingPhrase) rootPhrase = '';
      if (formState() == .entries) playerPhraseEntries.clear;
      if (formState() == .winners) winners.clear();
    });
  }

  String? prompt() {
    switch (formState()) {
      case .players:
        return 'Enter player name';
      case .startingPhrase:
        return 'Enter starting phrase';
      case .entries:
        return 'Enter derived phrase';
      case .winners:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (rootPhrase != '') Text(rootPhrase),
        Divider(),
        if (formState() == .players) PlayerList(players),
        if (formState() == .startingPhrase) Expanded(child: Placeholder()),
        if (formState() == .entries) PlayerEntries(playerPhraseEntries),
        if (formState() == .winners) Winners(winners),
        Divider(),
        Text(prompt() ?? '-'),
        Row(
          children: [
            Expanded(
              child: TextField(onChanged: (value) => inputValue = value),
            ),
            TextButton(
              onPressed: () => commitText(inputValue),
              child: Text('Enter'),
            ),
            TextButton(child: Text('Next'), onPressed: () => nextPage()),
          ],
        ),
      ],
    );
  }
}
