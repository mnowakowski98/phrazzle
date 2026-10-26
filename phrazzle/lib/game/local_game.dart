import 'package:flutter/material.dart';
import 'package:phrazzle/game/game.dart';
import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle, User;

class LocalGame extends StatefulWidget {
  final User user;
  final void Function() leaveGame;

  const LocalGame(this.user, this.leaveGame, {super.key});
  
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

  void enterPhrase(String phrase) => setState(() => game.addPhrase(playerId, phrase));

  void endRound() {
    setState(() {
      game.end();
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
      {playerId: widget.user},
      startGame: game.start,
      leaveGame: widget.leaveGame,
      startRound: startRound,
      enterPhrase: enterPhrase,
      endRound: endRound,
    );
  }
}