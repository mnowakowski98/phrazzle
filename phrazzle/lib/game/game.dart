import 'package:flutter/material.dart';
import 'package:phrazzle/game/lobby.dart';
import 'package:phrazzle/game/phrase_entry.dart';

import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle;

class Game extends StatelessWidget {
  final String playerId;
  final Phrazzle game;

  final void Function() startGame;
  final void Function() leaveGame;

  const Game(
    this.playerId,
    this.game, {
    required this.startGame,
    required this.leaveGame,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (game.isStarted == false) {
      return Lobby(
        playerId: playerId,
        game: game,
        startGame: startGame,
        leaveGame: leaveGame,
      );
    }
    if (game.isStarted == true && game.isEnded == false) return PhraseEntry();
    return Placeholder();
  }
}
