import 'package:flutter/material.dart';
import 'package:phrazzle/game/lobby.dart';
import 'package:phrazzle/game/phrase_entry.dart';
import 'package:phrazzle/game/round_start.dart';
import 'package:phrazzle/game/scores.dart';

import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle, User;

class Game extends StatelessWidget {
  final String playerId;
  final Phrazzle game;
  final Map<String, User> users;

  final void Function() startGame;
  final void Function() leaveGame;

  final void Function(String phrase) startRound;
  final void Function(String phrase) enterPhrase;
  final void Function() endRound;

  const Game(
    this.playerId,
    this.game,
    this.users, {
    required this.startGame,
    required this.leaveGame,
    required this.startRound,
    required this.enterPhrase,
    required this.endRound,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentRound = game.currentRound;
    if (game.isStarted == false) {
      return Lobby(
        game: game,
        startGame: startGame,
        leaveGame: leaveGame,
      );
    }

    if (game.isStarted == true && game.isEnded == false) {
      if (currentRound == null) {
        return RoundStart(startRound);
      } else {
        return PhraseEntry(currentRound.phraseGroups[playerId]!, enterPhrase, endRound);
      }
    }
    if (game.isStarted && game.isEnded) return Scores(game.currentRound!, users, leaveGame);

    return Placeholder();
  }
}
