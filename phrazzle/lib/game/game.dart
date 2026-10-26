import 'package:flutter/material.dart';
import 'package:phrazzle/game/lobby.dart';
import 'package:phrazzle/game/phrase_entry.dart';
import 'package:phrazzle/game/round_start.dart';

import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle;

class Game extends StatelessWidget {
  final String playerId;
  final Phrazzle game;

  final void Function() startGame;
  final void Function() leaveGame;

  final void Function(String phrase) startRound;

  const Game(
    this.playerId,
    this.game, {
    required this.startGame,
    required this.leaveGame,
    required this.startRound,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (game.isStarted == false) {
      return Lobby(
        game: game,
        startGame: startGame,
        leaveGame: leaveGame,
      );
    }

    if (game.isStarted == true && game.isEnded == false) {
      if (game.currentRound == null) {
        return RoundStart(startRound);
      } else {
        return PhraseEntry();
      }
    }
    return Placeholder();
  }
}
