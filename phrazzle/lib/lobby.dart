import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatefulWidget {
  final Phrazzle game;

  const Lobby(this.game, {super.key});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  String startingPhrase = '';
  bool get allowStart => startingPhrase.isNotEmpty;

  void startGame() async {
    await http.put(Uri.parse('http://localhost:3000/game/$startingPhrase'));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Focus(
                child: TextField(
                  decoration: InputDecoration(hintText: 'Starting phrase'),
                  onChanged: (value) => setState(() => startingPhrase = value),
                ),
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent || event.logicalKey != .enter) {
                    return .ignored;
                  }
                  if (allowStart) startGame();
                  return .handled;
                },
              ),
            ),
            TextButton(
              onPressed: allowStart ? startGame : null,
              child: Text('Start'),
            ),
          ],
        ),
        PlayerList(widget.game.players.values.toList()),
      ],
    );
  }
}
