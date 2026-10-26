import 'package:flutter/material.dart';
import 'package:phrazzle/game/game.dart';
import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle;

class LocalGame extends StatefulWidget {
  final void Function() onGameEnd;

  const LocalGame(this.onGameEnd, {super.key});
  
  @override
  State<LocalGame> createState() => _LocalGameState();
}

class _LocalGameState extends State<LocalGame> {
  final Phrazzle game = Phrazzle();
  String get playerId => game.players.first;

  void startRound(String phrase) {
    setState(() {
      final round = game.createRound(phrase);
      game.currentRoundId = round.id;
    });
  }

  @override
  void initState() {
    super.initState();
    game.addPlayer();
    game.start();
  }

  @override
  Widget build(BuildContext context) {
    return Game(
      playerId,
      game,
      startGame: game.start,
      leaveGame: widget.onGameEnd,
      startRound: startRound,
    );
  }
}