import 'package:flutter/material.dart';
import 'package:phrazzle/player_tile.dart';

import 'package:phrazzle_lib/phrazzle.dart';

class PlayerList extends StatelessWidget {
  final List<Player> players;

  const PlayerList(this.players, {super.key});

  @override
  build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            title: Text('Players'),
            titleTextStyle: TextStyle(
              fontWeight: .bold,
              color: Colors.lightBlue,
            ),
          ),
          for (final player in players) PlayerTile(player),
        ],
      ),
    );
  }
}
