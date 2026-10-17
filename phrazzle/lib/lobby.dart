import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;
import 'package:phrazzle/env.dart';

import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatefulWidget {
  final Phrazzle game;
  final String gameId;
  final String playerId;

  const Lobby(this.game, this.gameId, this.playerId, {super.key});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  String startingPhrase = '';
  bool get allowStart => startingPhrase.isNotEmpty;

  void startGame() async {
    await http.put(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/$startingPhrase'));
  }

  void leaveGame() async {
    await http.delete(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/${widget.playerId}'));
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
        Divider(),
        PlayerList(widget.game.players.values.toList()),
        Divider(),
        Text('Game code'),
        Text(widget.gameId.substring(0, 5).toUpperCase(), style: TextStyle(fontSize: 18, color: Colors.cyan)),
        Divider(),
        TextButton(onPressed: leaveGame, child: Text('Leave', style: TextStyle(color: Colors.red),)),
      ],
    );
  }
}
