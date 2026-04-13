import 'package:flutter/material.dart';

class _Player {
  final String id;
  final String name;
  int score = 0;

  _Player(this.id, this.name, this.score);
}

enum _FormState { players, rootPhrase, entries, winners }

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final players = <_Player>[];
  String inputValue = '';
  String prompt = 'Enter player name:';
  _FormState formState = .players;

  void commitText(String text) {
    if (text.isEmpty) return;

    switch (formState) {
      case .players:
        setState(() => players.add(_Player(text, text, 0)));
        break;
      case .rootPhrase:
        break;
      case .entries:
        break;
      case .winners:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (final text) => setState(() {
                  inputValue = text;
                }),
              ),
            ),
            TextButton(
              onPressed: () => commitText(inputValue),
              child: Text('Enter'),
            ),
          ],
        ),
        Text(prompt),
        Expanded(
          child: ListView(
            children: [
              for (final player in players)
                Text('${player.id} - ${player.name} - ${player.score}'),
            ],
          ),
        ),
      ],
    );
  }
}
