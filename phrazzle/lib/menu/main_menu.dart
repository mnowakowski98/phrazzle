import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class MainMenu extends StatefulWidget {
  final User user;

  final void Function() startLocalGame;

  const MainMenu(this.user, {required this.startLocalGame, super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  var editingPlayerName = false;
  var playerNameText = '';

  @override
  Widget build(BuildContext context) {   
      final user = widget.user;   
      return Column(
        children: [
          if (user.id.isNotEmpty) Column(
            children: [
              UserTile(user),
              Divider(),
            ],
          ),
          ElevatedButton(onPressed: widget.startLocalGame, child: Text('Single player game')),
          Divider(),
        ],
      );
  }
}