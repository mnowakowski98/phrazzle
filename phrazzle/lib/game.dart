import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  final _nameController = TextEditingController();

  WebSocketChannel? _channel;
  String? playerId;

  void joinGame(String playerName) {
    if (playerName.isEmpty) return;
    setState(() {
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000/game/$playerName'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: TextField(controller: _nameController)),
            TextButton(
              onPressed: () {
                joinGame(_nameController.text);
              },
              child: Text('Join'),
            ),
          ],
        ),
        Text(playerId ?? ''),
        StreamBuilder(
          stream: _channel?.stream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == .none ||
                snapshot.connectionState == .done) {
              return Text('Not connected');
            }
            if (snapshot.connectionState == .waiting) return Text('Loading');
            final Map<String, dynamic> jsonData = jsonDecode(snapshot.data);
            return PlayerList([
              for (final Map<String, dynamic> playerJson
                  in jsonData['players'].values)
                Player.fromJson(playerJson),
            ], '');
          },
        ),
      ],
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _channel?.sink.close();
    super.dispose();
  }
}
