import 'package:flutter/material.dart';
import 'package:phrazzle/game/lobby.dart';
import 'package:phrazzle/game/phrase_entry.dart';
import 'package:phrazzle/game/round_start.dart';
import 'package:phrazzle/game/scores.dart';

import 'package:phrazzle_lib/phrazzle.dart' show GameInfo, User;

class Game extends StatelessWidget {
  final String playerId;
  final GameInfo game;
  final Map<String, User> playerUsers;

  final void Function() startGame;
  final void Function() leaveGame;

  final void Function(String phrase) startRound;
  final void Function(String phrase) enterPhrase;
  final void Function() endRound;

  final Widget? bottomSpace;

  const Game(
    this.playerId,
    this.game,
    this.playerUsers, {
    required this.startGame,
    required this.leaveGame,
    required this.startRound,
    required this.enterPhrase,
    required this.endRound,
    this.bottomSpace,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final currentRound = game.rounds[game.currentRoundId];
    final bottomSpace = this.bottomSpace;

    Widget gameWidget = Placeholder();

    if (game.isStarted == false) {
      gameWidget = Lobby(
        playerUsers,
        startGame: startGame,
      );
    }

    if (game.isStarted == true && game.isEnded == false) {
      if (currentRound == null) {
        gameWidget = RoundStart(startRound);
      } else {
        gameWidget = PhraseEntry(playerId, currentRound, playerUsers, enterPhrase, endRound);
      }
    }

    if (game.isStarted && game.isEnded && currentRound != null) gameWidget = Scores(currentRound, playerUsers);

    return Column(children: [
      Expanded(child: gameWidget),
      Divider(),
      if (bottomSpace != null) Column(children: [bottomSpace, Divider()],),
      TextButton(onPressed: leaveGame, child: Text('Leave', style: TextStyle(color: Colors.red),))
    ],);
  }
}
