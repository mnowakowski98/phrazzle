import 'package:flutter/material.dart';
import 'package:phrazzle/player_entry.dart';
import 'package:phrazzle_lib/phrazzle.dart';

enum _FormState { players, rootPhrase, entries, winners }

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  String inputValue = '';
  static const List<_FormState> formStates = [
    .players,
    .rootPhrase,
    .entries,
    .winners,
  ];
  int formStateIndex = 0;
  _FormState formState() => formStates[formStateIndex];

  final game = Phrazzle();

  final players = <Player>[];
  String rootPhrase = '';

  void addPlayer(String playerName) {
    setState(() {
      players.add(Player(game.addPlayer(), playerName, 0));
    });
  }

  void nextPage() {
    setState(() {
      formStateIndex++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (formStateIndex == 0) PlayerList(players),
        Row(
          children: [
            Expanded(
              child: TextField(onChanged: (value) => inputValue = value),
            ),
            TextButton(
              onPressed: () => addPlayer(inputValue),
              child: Text('Enter'),
            ),
            TextButton(child: Text('Next'), onPressed: () => nextPage()),
          ],
        ),
      ],
    );
  }
}
