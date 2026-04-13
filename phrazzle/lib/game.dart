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
  String inputValue = '';
  _FormState formState = .players;

  final players = <_Player>[];
  String rootPhrase = '';
  int playerEntriesIndex = 0;
  final entries = <String>[];

  String prompt() {
    switch (formState) {
      case .players:
        return 'Enter player name:';
      case .rootPhrase:
        return 'Enter starting phrase';
      case .entries:
        return 'Enter entries:';
      case .winners:
        return 'Winners:';
    }
  }

  void commitText(String text) {
    if (text.isEmpty) return;

    setState(() {
      switch (formState) {
        case .players:
          players.add(_Player(text, text, 0));
          break;
        case .rootPhrase:
          rootPhrase = inputValue;
          break;
        case .entries:
          entries.add(text);
          break;
        case .winners:
          break;
      }
    });
  }

  void end() {
    setState(() {
      switch (formState) {
        case .players:
          rootPhrase = '';
          formState = .rootPhrase;
          break;
        case .rootPhrase:
          entries.clear();
          formState = .entries;
          break;
        case .entries:
          players[playerEntriesIndex].score = 0; // TODO: Get score from lib
          if (++playerEntriesIndex >= players.length) {
            formState = .winners;
          }
          entries.clear();
          break;
        case .winners:
          players.clear();
          formState = .players;
          break;
      }
    });
  }

  ListView? getList() {
    switch (formState) {
      case .players:
        return ListView(
          children: [
            for (final player in players)
              Text('${player.id} - ${player.name} - ${player.score}'),
          ],
        );
      case .rootPhrase:
        return null;
      case .entries:
        return ListView(children: [for (final entry in entries) Text(entry)]);
      case .winners:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text(rootPhrase),
        Text(prompt()),
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
        Expanded(child: getList() ?? Text('No data')),
        TextButton(onPressed: end, child: Text('End')),
      ],
    );
  }
}
