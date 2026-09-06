import 'package:flutter/material.dart';
import 'package:phrazzle/player_tile.dart';

import 'package:phrazzle_lib/phrazzle.dart';

class PlayerList extends StatefulWidget {
  final List<Player> players;

  const PlayerList(this.players, {super.key});

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
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
          for (final player in widget.players) PlayerTile(player),
        ],
      ),
    );
  }
}
