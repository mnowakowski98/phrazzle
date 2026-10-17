import 'package:flutter/material.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class PlayerTile extends StatelessWidget {
  final Player player;

  const PlayerTile(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(player.name, style: TextStyle(fontSize: 18))),
        if (player.score > 0) Text(player.score.toString()),
      ],
    );
  }
}
