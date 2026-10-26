import 'package:flutter/material.dart';
import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatefulWidget {
  final Phrazzle game;

  final void Function() startGame;

  const Lobby({
    super.key,
    required this.game,
    required this.startGame,
  });

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: widget.startGame,
            child: Text('Start'),
          ),
        ),

      ],
    );
  }
}
