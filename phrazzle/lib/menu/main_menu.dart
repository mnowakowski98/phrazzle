import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazzle/menu/ongoing_games.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class MainMenu extends StatefulWidget {
  final User user;

  final void Function() startLocalGame;
  final void Function() startConnectedGame;
  final void Function(String gameCode, [String? playerId]) joinConnectedGame;
  final void Function()? logout;

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

  final tabs = [];

  @override
  Widget build(BuildContext context) {   
      final user = widget.user;
      final logout = widget.logout;

      return DefaultTabController(
        length: 2,
        child: Column(
          children: [
            if (user.name.isNotEmpty) Text(user.name, style: TextStyle(color: Colors.teal, fontSize: 28, fontWeight: .bold),),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TabBar(tabs: [Text('Start'), Text('Active')]),
            ),
            Expanded(
              child: TabBarView(
                children: [Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ElevatedButton(onPressed: widget.startLocalGame, child: Text('Single player')),
                    ),
                    Divider(),
                    if (user.isUser) Column(children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ElevatedButton(onPressed: widget.startConnectedGame, child: Text('Host')),
                      ),
                      Text('or'),
                      Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Text('Enter a game code', style: TextStyle(color: Colors.teal, fontSize: 16),),
                              Focus(
                                child: TextField(
                                  controller: _gameCodeController,
                                  textAlign: .center,
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
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                            child: ElevatedButton(
                              onPressed: gameCode.isNotEmpty
                                  ? () => widget.joinConnectedGame(gameCode)
                                  : null,
                              child: Text('Join'),
                            ),
                      ),
                    ],),
                  ],
                ),
                OngoingGames(user, (gameCode, playerId) => widget.joinConnectedGame(gameCode, playerId)),
              ]),
            ),
          if (widget.logout != null)
            Divider(),
            OutlinedButton(
              onPressed: logout,
              child: Text(
                user.isUser ? 'Logout' : 'Login',
                style: TextStyle(
                  color: user.isUser ? Colors.orange : Colors.green,
                ),
              ),
            ),
          ],
        ),
      );
  }
}