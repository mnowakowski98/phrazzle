import 'package:flutter/material.dart';
import 'package:phrazzle/player.dart';
import 'package:phrazzle/player_tile.dart';

class Winners extends StatelessWidget {
  final List<Player> players;

  const Winners(this.players, {super.key});

  @override
  Widget build(BuildContext context) {
    final maxScore = players.fold(
      0,
      (int max, final player) => player.score > max ? player.score : max,
    );
    final winners = players.where((player) => player.score == maxScore);
    final others = players.where((player) => player.score < maxScore);

    return Expanded(
      child: ListView(
        children: [
          ListTile(
            title: Text(winners.length > 1 ? 'Winners' : 'Winner'),
            titleTextStyle: TextStyle(
              fontWeight: .bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          for (final winner in winners) PlayerTile(winner),
          if (others.isNotEmpty) ListTile(title: Text('Everyone else')),
          for (final player in others) PlayerTile(player),
        ],
      ),
    );
  }
}
