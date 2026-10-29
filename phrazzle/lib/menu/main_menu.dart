import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class MainMenu extends StatefulWidget {
  final User user;

  final void Function() startLocalGame;
  final void Function() startConnectedGame;
  final void Function(String gameCode) joinConnectedGame;
  final void Function() logout;

  const MainMenu(
    this.user, {
    required this.startLocalGame,
    required this.startConnectedGame,
    required this.joinConnectedGame,
    required this.logout,
    super.key,
  });

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  var gameCode = '';
  final _gameCodeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _gameCodeController.addListener(() => setState(() => gameCode = _gameCodeController.text));
  }

  @override
  void dispose() {
    _gameCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {   
      final user = widget.user;

      return Column(
        children: [
          Column(
            children: [
              if (user.id.isNotEmpty) Column(children: [
                UserTile(user),
                  Divider(),
                ElevatedButton(onPressed: widget.startConnectedGame, child: Text('Start new game')),
                Divider(),
                Text('or'),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Focus(child: TextField(controller: _gameCodeController, decoration: InputDecoration(hintText: 'Enter a game code'),),),
                ),
                ElevatedButton(onPressed: gameCode.isNotEmpty ? () => widget.joinConnectedGame(gameCode) : null, child: Text('Join game')),
              ],)
            ],
          ),
          Expanded(child: Center(child: ElevatedButton(onPressed: widget.startLocalGame, child: Text('Single player')),)),
          Divider(),
          TextButton(onPressed: widget.logout, child: Text(user.id.isNotEmpty ? 'Logout' : 'Login'),)
        ],
      );
  }
}