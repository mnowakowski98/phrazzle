import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class MainMenu extends StatefulWidget {
  final User user;

  final void Function() startLocalGame;
  final void Function()? startConnectedGame;
  final void Function(String gameCode)? joinConnectedGame;
  final void Function()? logout;

  const MainMenu(
    this.user, {
    required this.startLocalGame,
    this.startConnectedGame,
    this.joinConnectedGame,
    this.logout,
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
      final startConnectedGame = widget.startConnectedGame;
      final joinConnectedGame = widget.joinConnectedGame;
      final allowConnectedGame = user.isUser == true && startConnectedGame != null && joinConnectedGame != null;
      final logout = widget.logout;

      return Column(
        children: [
          Column(
            children: [
              if (allowConnectedGame) Column(children: [
                UserTile(user),
                Divider(),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: startConnectedGame, child: Text('Start new game')),
                ),
                Text('or'),
                Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Focus(
                      child: TextField(
                        controller: _gameCodeController,
                        decoration: InputDecoration(
                          hintText: 'Enter a game code',
                        ),
                        inputFormatters: [
                          TextInputFormatter.withFunction((oldValue, newValue) {
                            if (newValue.text.length > 5) return oldValue;
                            return newValue.copyWith(
                              text: newValue.text.toUpperCase(),
                            );
                          }),
                        ],
                        style: TextStyle(color: Colors.cyan),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(onPressed: gameCode.isNotEmpty ? () => joinConnectedGame(gameCode) : null, child: Text('Join game')),
                ),
                Divider(),
              ],)
            ],
          ),
          Expanded(child: Center(child: ElevatedButton(onPressed: widget.startLocalGame, child: Text('Single player')),)),
          if (logout != null) Column(
            children: [
              Divider(),
              OutlinedButton(onPressed: logout, child: Text(user.isUser ? 'Logout' : 'Login', style: TextStyle(color: user.isUser ? Colors.orange : null),),)
            ],
          ),
        ],
      );
  }
}