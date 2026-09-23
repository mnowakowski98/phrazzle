import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazzle/phrase_entry.dart';
import 'package:phrazzle/winners.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/lobby.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Game extends StatefulWidget {
  const Game({super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  String playerName = '';
  bool get allowJoin => playerName.isNotEmpty;

  WebSocketChannel? _channel;
  String? playerId;

  Phrazzle? game;
  Round? round;

  // TODO: Remove hardcoded urls
  void joinGame() async {
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
  void dispose() {
    _channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (playerId == null) {
      return Row(
        children: [
          Expanded(
            child: Focus(
              child: TextField(
                decoration: InputDecoration(hintText: 'Enter a player name'),
                onChanged: (value) => setState(() => playerName = value),
              ),
              onKeyEvent: (node, event) {
                if (event is KeyUpEvent || event.logicalKey != .enter) {
                  return .ignored;
                }
                if (allowJoin) joinGame();
                return .handled;
              },
            ),
          ),
          TextButton(
            onPressed: allowJoin ? joinGame : null,
            child: Text('Join'),
          ),
        ],
      );
    }

    if (game?.isStarted == false && game?.isEnded == false) return Lobby(game!);
    if (game?.isStarted == true && game?.isEnded == false && round != null) {
      return PhraseEntry(round!, playerId!);
    }
    if (game?.isStarted == true && game?.isEnded == true) {
      return Winners(
        game!.players.entries
            .where((player) => game!.winners.contains(player.key))
            .map((player) => player.value),
      );
    }

    return Placeholder();
  }
}
