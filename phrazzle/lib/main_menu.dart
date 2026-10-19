import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MainMenu extends StatefulWidget {
  final String initialDisplayName;
  final void Function(String playerName) createGame;
  final void Function(String playerName, String gameCode) joinGame;

  const MainMenu(this.initialDisplayName, {super.key, required this.createGame, required this.joinGame,});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  var playerNameText = '';
  var gameCodeText = '';

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _nameController.text = widget.initialDisplayName;
      playerNameText = widget.initialDisplayName;
    });
    _nameController.addListener(() => setState(() => playerNameText = _nameController.text));
    _codeController.addListener(() => setState(() => gameCodeText = _codeController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canJoinGame = playerNameText.isNotEmpty && gameCodeText.isNotEmpty;
      
      return Column(
        children: [
          TextField(
            controller: _nameController, decoration: InputDecoration(hintText: 'Display name'),
            textAlign: .center,
            style: TextStyle(fontSize: 24),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: playerNameText.isNotEmpty ? () {
              widget.createGame(playerNameText);
              setState(() => _codeController.clear());
            } : null, child: Text('Start new game')),
          ),
          Divider(),
          Text('or'),
          Divider(),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(hintText: 'Enter a game code'),
            inputFormatters: [TextInputFormatter.withFunction((oldValue, newValue) {
              if (newValue.text.length > 5) return oldValue;
              return newValue.copyWith(text: newValue.text.toUpperCase());
            })],
            textAlign: .center,
            style: TextStyle(color: Colors.cyan, fontSize: 22),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: canJoinGame ? () {
                widget.joinGame(playerNameText, gameCodeText);
                setState(() => _codeController.clear());
              } : null,
              child: Text('Join game')
            ),
          ),
        ],
      );
  }
}