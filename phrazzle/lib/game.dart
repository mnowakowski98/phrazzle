import 'package:flutter/material.dart';
import 'package:phrazzle_lib/phrazzle.dart';

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

  final game = Phrazzle();

  final players = <_Player>[];
  String rootPhrase = '';
  int playerEntriesIndex = 0;
  final entries = <String>[];
  final winners = <_Player>[];

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
          final id = game.addPlayer();
          players.add(_Player(id, text, 0));
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
          game.start();
          formState = .entries;
          break;
        case .entries:
          final player = players[playerEntriesIndex];
          final score = game.incrementScore(
            player.id,
            Phrazzle.scorePhrases(rootPhrase, entries),
          );
          player.score = score;
          if (++playerEntriesIndex >= players.length) {
            winners.clear();
            final winnerIds = game.end();
            winners.addAll(
              players.where((final player) => winnerIds.contains(player.id)),
            );
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
        return ListView(
          children: [
            for (final winner in winners)
              Text('Player: ${winner.name} - Score: ${winner.score}'),
          ],
        );
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
