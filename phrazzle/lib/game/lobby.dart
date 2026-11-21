import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatefulWidget {
  final Map<String, User> users;

  final void Function() startGame;

  const Lobby(this.users, {
    super.key,
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
        Text('Players', style: TextStyle(color: Colors.teal, fontSize: 24),),
        Divider(),
        Expanded(child: ListView(children: [
          for (final user in widget.users.values) UserTile(user)
        ],)),
        Divider(),
        ElevatedButton(
          onPressed: widget.startGame,
          child: Text('Start'),
        ),

      ],
    );
  }
}
