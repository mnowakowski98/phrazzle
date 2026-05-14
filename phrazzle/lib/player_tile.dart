import 'package:flutter/material.dart';
import 'package:phrazzle/player.dart';

class PlayerTile extends StatelessWidget {
  final Player player;

  const PlayerTile(this.player, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(player.name),
      subtitle: Text(player.score.toString()),
    );
  }
}
