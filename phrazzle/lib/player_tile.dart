import 'package:flutter/material.dart';

class PlayerTile extends StatelessWidget {
  final String name;
  final int? score;

  const PlayerTile(this.name, {this.score, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(name, style: TextStyle(fontSize: 18))),
        if (score != null) Text(score.toString()),
      ],
    );
  }
}
