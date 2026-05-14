import 'package:flutter/material.dart';
import 'package:phrazzle/player.dart';
import 'package:phrazzle/player_entries.dart';
import 'package:phrazzle/player_list.dart';
import 'package:phrazzle/starting_phrase.dart';
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
  String startingPhrase = '';

  final playerNames = <String, String>{};
  final playerPhraseEntries = <String, List<String>>{};
  List<Player> players() {
    final players = <Player>[];
    for (final player in game.scores.entries) {
      players.add(Player(player.key, playerNames[player.key]!, player.value));
    }
    return players;
  }

  void nextPage() {
    setState(() {
      final isEntryForm = formState() == .entries;

      // Score entries if end of player entries
      if (isEntryForm) {
        final player = players()[playerIndex];
        final score = Phrazzle.scorePhrases(
          startingPhrase,
          playerPhraseEntries[player.id]!,
        );
        player.score = game.incrementScore(player.id, score);
      }

      final isEndOfPlayerEntries =
          isEntryForm && ++playerIndex >= players().length;

      final nextFormExists = formStateIndex + 1 < formStates.length;

      // Move to next form state
      if ((isEntryForm == false || isEndOfPlayerEntries) && nextFormExists) {
        formStateIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final hasStartingPhrase = startingPhrase != '';
    return Column(
      crossAxisAlignment: .start,
      children: [
        if (hasStartingPhrase) Text(startingPhrase),
        if (hasStartingPhrase) Divider(),
        if (formState() == .players)
          PlayerList(
            players(),
            allowEdit: true,
            onPlayerAdd: (name) =>
                setState(() => playerNames[game.addPlayer()] = name),
            onDone: () {
              if (players().isEmpty) return;
              setState(() => formStateIndex++);
            },
          ),
        if (formState() == .startingPhrase)
          StartingPhrase((final phrase) => startingPhrase = phrase),
        if (formState() == .entries)
          PlayerEntries(
            (final entries) => setState(() {
              playerPhraseEntries[players()[playerIndex].id] = entries;
              nextPage();
            }),
          ),
        if (formState() == .winners) Winners(players()),
      ],
    );
  }
}
