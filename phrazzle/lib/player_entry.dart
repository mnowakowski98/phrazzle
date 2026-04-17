import 'package:flutter/material.dart';

class Player {
  final String id;
  final String name;
  int score = 0;

  Player(this.id, this.name, this.score);
}

class PlayerList extends StatelessWidget {
  final List<Player> players;

  const PlayerList(this.players, {super.key});

  @override
  build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          for (final player in players) ListTile(title: Text(player.name)),
        ],
      ),
    );
  }
}
