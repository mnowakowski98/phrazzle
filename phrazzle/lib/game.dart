import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phrazzle/env.dart';
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
  var playerNameText = '';
  var gameCodeText = '';

  WebSocketChannel? channel;
  String? connectedGameId;
  String? connectedPlayerId;

  Phrazzle? game;
  Round? round;

  final _nameController = TextEditingController();
  final _gameIdController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _nameController.addListener(() => setState(() => playerNameText = _nameController.text));
    _gameIdController.addListener(() => setState(() => gameCodeText = _gameIdController.text));
  }

  @override
  void dispose() {
    channel?.sink.close();
    _nameController.dispose();
    _gameIdController.dispose();
    super.dispose();
  }

  void connect(String gameId, String playerId) {
    setState(() {
      connectedGameId = gameId;
      connectedPlayerId = playerId;

      channel = WebSocketChannel.connect(Uri.parse('${Env.gameUrl}/game/$gameId/$playerId'));
      channel!.sink.done.whenComplete(() {
        setState(() {
          connectedGameId = null;
          connectedPlayerId = null;
          game = null;
          round = null;
        });
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

  void createGame() async {
    if (playerNameText.isEmpty) return;

    final createResponse = await http.post(Uri.parse('${Env.centralUrl}/game'));
    final newGameId = createResponse.body;
    final addPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$newGameId/$playerNameText'));
    final newPlayerId = addPlayerResponse.body;
    connect(newGameId, newPlayerId);
    setState(() => _gameIdController.clear());
  }

  void joinGame() async {
    if (playerNameText.isEmpty || gameCodeText.isEmpty) return;

    final res = await http.post(Uri.parse('${Env.centralUrl}/game/$gameCodeText/$playerNameText'));
    connect(gameCodeText, res.body);
    setState(() => _gameIdController.clear());
  }

  @override
  Widget build(BuildContext context) {
    if (connectedPlayerId == null) {
      return Column(
        children: [
          TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Display name')),
          Divider(),
          TextButton(onPressed: playerNameText.isNotEmpty ? createGame : null, child: Text('Start new game')),
          Divider(),
          Text('or'),
          Divider(),
          TextField(controller: _gameIdController, decoration: InputDecoration(hintText: 'Enter a game code'),),
          TextButton(onPressed: (playerNameText.isNotEmpty && gameCodeText.isNotEmpty) ? joinGame : null, child: Text('Join game')),
        ],
      );
    }

    if (game?.isStarted == false && game?.isEnded == false) return Lobby(game!, connectedGameId!);
    if (game?.isStarted == true && game?.isEnded == false && round != null) {
      return PhraseEntry(round!, connectedGameId!, connectedPlayerId!);
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
