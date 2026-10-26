import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class MainMenu extends StatelessWidget {
  final User user;

  final void Function() startLocalGame;
  final void Function() logout;

  const MainMenu(
    this.user, {
    required this.startLocalGame,
    required this.logout,
    super.key,
  });

  @override
  Widget build(BuildContext context) {   
      final user = this.user;

      return Column(
        children: [
          Expanded(
            child: Column(
              children: [
                if (user.id.isNotEmpty) Column(
                  children: [
                    UserTile(user),
                    Divider(),
                  ],
                ),
                ElevatedButton(onPressed: startLocalGame, child: Text('Single player game')),
                Divider(),
              ],
            ),
          ),
          TextButton(onPressed: logout, child: Text(user.id.isNotEmpty ? 'Logout' : 'Login'),)
        ],
      );
  }
}