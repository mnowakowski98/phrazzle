import 'package:flutter/material.dart';
import 'package:phrazzle/player_list.dart';

class Winners extends StatelessWidget {
  final List<Player> winners;

  const Winners(this.winners, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          for (final winner in winners) ListTile(title: Text(winner.name)),
        ],
      ),
    );
  }
}
