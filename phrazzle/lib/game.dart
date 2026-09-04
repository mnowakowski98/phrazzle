import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/game_lobby.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  var enableJoinButton = false;
  final _nameController = TextEditingController();

  WebSocketChannel? _channel;
  String? playerId;

  Phrazzle? game;
  Round? round;

  void joinGame(String playerName) async {
    if (playerName.isEmpty) return;
    final res = await http.post(
      Uri.parse('http://localhost:3000/game/$playerName'),
    );
    setState(() {
      playerId = res.body;
      _channel = WebSocketChannel.connect(
        Uri.parse('ws://localhost:3000/game/$playerId'),
      );

      _channel?.sink.done.whenComplete(() {
        setState(() {
          playerId = null;
          game = null;
          round = null;
        });
      });

      _channel?.stream.listen((data) {
        final json = jsonDecode(data);
        switch (json['typeKey']) {
          case 'game':
            setState(() => game = Phrazzle.fromJson(json));
            break;
          case 'round':
            setState(() => round = Round.fromJson(json));
            break;
        }
      });
    });
  }

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() {
      setState(() => enableJoinButton = _nameController.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (playerId == null)
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(hintText: 'Enter a player name'),
                ),
              ),
              TextButton(
                onPressed: enableJoinButton
                    ? () {
                        joinGame(_nameController.text);
                      }
                    : null,
                child: Text('Join'),
              ),
            ],
          ),
        if (game?.isStarted == false && game?.isEnded == false)
          GameLobby(game!),
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
