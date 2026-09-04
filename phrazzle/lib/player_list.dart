import 'package:flutter/material.dart';
import 'package:phrazzle/player_tile.dart';

import 'package:phrazzle_lib/phrazzle.dart';

class PlayerList extends StatefulWidget {
  final List<Player> players;
  final String localPlayerId;

  const PlayerList(this.players, this.localPlayerId, {super.key});

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  var inputText = '';

  @override
  build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            title: Text('Players'),
            titleTextStyle: TextStyle(
              fontWeight: .bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
          for (final player in widget.players) PlayerTile(player),
        ],
      ),
    );
  }
}
