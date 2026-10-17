import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/connected_game.dart';
import 'package:phrazzle/env.dart';
import 'package:phrazzle/player_list.dart';

class Scores extends StatelessWidget {
  final ConnectedGame connectedGame;

  const Scores(this.connectedGame, {super.key});

  void leaveGame() async {
    await http.delete(Uri.parse('${Env.centralUrl}/game/${connectedGame.gameId}/${connectedGame.playerId}'));
  }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: [
        PlayerList(connectedGame, connectedGame.game.winners.length > 1 ? 'Winners' : 'Winner', true),
        TextButton(onPressed: leaveGame, child: Text('Leave', style: TextStyle(color: Colors.lightGreen),))
      ],
    );
  }
}
