import 'package:flutter/material.dart';
import 'package:phrazzle/connected_game.dart';
import 'package:phrazzle/player_tile.dart';

class PlayerList extends StatelessWidget {
  final ConnectedGame connectedGame;
  final String text;
  final bool showScores;

  const PlayerList(this.connectedGame, this.text, this.showScores, {super.key});

  @override
  build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          children: [
            Text(text, style: TextStyle(
              fontSize: 20,
              fontWeight: .bold,
              color: Colors.lightBlue,
            ),),
            // for (final player in connectedGame.game.players.values) PlayerTile(player.name, score: showScores ? player.score : null,),
          ],
        ),
      ),
    );
  }
}
