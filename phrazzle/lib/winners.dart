import 'package:flutter/material.dart';
import 'package:phrazzle/player_tile.dart';

import 'package:phrazzle_lib/phrazzle.dart';

class Winners extends StatelessWidget {
  final Map<String, Player> players;

  const Winners(this.players, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ListTile(
          title: Text(players.length > 1 ? 'Winners' : 'Winner'),
          titleTextStyle: TextStyle(fontWeight: .bold, color: Colors.blue),
        ),
        for (final player in players.values) PlayerTile(player),
      ],
    );
  }
}
