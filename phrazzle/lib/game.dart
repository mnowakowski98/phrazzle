import 'package:flutter/material.dart';
import 'package:phrazzle/player_entries.dart';
import 'package:phrazzle/player_list.dart';
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
      if (formStateIndex + 1 < formStates.length) formStateIndex++;
      if (formState() == .players) players.clear();
      if (formState() == .startingPhrase) rootPhrase = '';
      if (formState() == .entries) playerPhraseEntries.clear;
      if (formState() == .winners) winners.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (formState() == .players) PlayerList(players),
        if (formState() == .startingPhrase) Expanded(child: Placeholder()),
        if (formState() == .entries) PlayerEntries(playerPhraseEntries),
        if (formState() == .winners) Expanded(child: Placeholder()),
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
