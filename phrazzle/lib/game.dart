import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazzle/connected_game.dart';
import 'package:phrazzle/env.dart';
import 'package:phrazzle/phrase_entry.dart';
import 'package:phrazzle/scores.dart';
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
  var playerNameText = '';
  var gameCodeText = '';

  WebSocketChannel? channel;
  String? connectedGameId;
  String? connectedPlayerId;

  Phrazzle? game;
  Round? round;

  final _nameController = TextEditingController();
  final _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() => playerNameText = _nameController.text));
    _codeController.addListener(() => setState(() => gameCodeText = _codeController.text));
  }

  @override
  void dispose() {
    channel?.sink.close();
    _nameController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  void connect(String gameId, String playerId) {
    setState(() {
      connectedGameId = gameId;
      connectedPlayerId = playerId;

      channel = WebSocketChannel.connect(Uri.parse('${Env.gameUrl}/game/$gameId/$playerId'));
      channel!.sink.done.whenComplete(() {
        if (channel?.closeCode == 1000) {
          setState(() {
            connectedGameId = null;
            connectedPlayerId = null;
            game = null;
            round = null;
          });
        }
      });

      channel?.stream.listen((data) {
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

  void disconnect() async {
    channel?.sink.close(1000);
    channel = null;
    setState(() {
      connectedGameId = null;
      connectedPlayerId = null;
      game = null;
      round = null;
    });
  }

  void createGame() async {
    if (playerNameText.isEmpty) return;

    final createResponse = await http.post(Uri.parse('${Env.centralUrl}/game'));
    final newGameId = createResponse.body;
    final addPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$newGameId/$playerNameText'));
    connect(newGameId, addPlayerResponse.body);
    setState(() => _codeController.clear());
  }

  void joinGame() async {
    if (playerNameText.isEmpty || gameCodeText.isEmpty) return;

    final gameIdResponse = await http.get(Uri.parse('${Env.centralUrl}/game/$gameCodeText'));
    final gameId = gameIdResponse.body;
    final addPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$gameId/$playerNameText'));
    connect(gameId, addPlayerResponse.body);
    setState(() => _codeController.clear());
  }

  @override
  Widget build(BuildContext context) {
    if (connectedPlayerId == null) {
      final canJoinGame = playerNameText.isNotEmpty && gameCodeText.isNotEmpty;
      final canRejoinGame = connectedGameId != null;
      
      return Column(
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Display name')),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(onPressed: playerNameText.isNotEmpty ? createGame : null, child: Text('Start new game')),
          ),
          Divider(),
          Text('or'),
          Divider(),
          TextField(
            controller: _codeController,
            decoration: InputDecoration(hintText: 'Enter a game code'),
            inputFormatters: [TextInputFormatter.withFunction((_, newValue) => newValue.copyWith(text: newValue.text.toUpperCase()))],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: canRejoinGame ? () => connect(connectedGameId!, connectedPlayerId!) : canJoinGame ? joinGame : null,
              child: Text('Join game')
            ),
          ),
        ],
      );
    }

    if (game?.isStarted == false && game?.isEnded == false) return Lobby(ConnectedGame(connectedGameId!, connectedPlayerId!, game!));
    if (game?.isStarted == true && game?.isEnded == false && round != null) {
      return PhraseEntry(ConnectedGame(connectedGameId!, connectedPlayerId!, game!, round!));
    }
    if (game?.isStarted == true && game?.isEnded == true) {
      return Scores(ConnectedGame(connectedGameId!, connectedPlayerId!, game!, round!), disconnect);
    }

    return Placeholder();
  }
}
