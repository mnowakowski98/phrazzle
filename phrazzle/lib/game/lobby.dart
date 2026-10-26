import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatefulWidget {
  final Phrazzle game;
  final String playerId;

  final void Function() startGame;
  final void Function() leaveGame;

  const Lobby({
    super.key,
    required this.game,
    required this.playerId,
    required this.startGame,
    required this.leaveGame,
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
          child: Row(
            mainAxisAlignment: .spaceEvenly,
            children: [
              TextButton(onPressed: widget.leaveGame, child: Text('Leave', style: TextStyle(color: Colors.red),)),
              ElevatedButton(
                onPressed: widget.startGame,
                child: Text('Start'),
              ),
            ],
          ),
        ),

      ],
    );
  }
}
