import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phrazzle/env.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/game/game.dart';
import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle, User;

/// State manager for games that connect to the central app
class ConnectedGame extends StatefulWidget {
  final String gameId;
  final String playerId;
  final void Function() leaveGame;

  const ConnectedGame(
    this.gameId,
    this.playerId,
    this.leaveGame, {
    super.key,
  });

  @override
  State<ConnectedGame> createState() => _ConnectedGameState();
}

class _ConnectedGameState extends State<ConnectedGame> {
  Phrazzle game = Phrazzle();
  WebSocketChannel? channel;

  final playerUsers = <String, User>{};
  var gameCode = '';

  void connect() async {
    final channel = WebSocketChannel.connect(Uri.parse('${Env.gameUrl}/game/${widget.gameId}/player/${widget.playerId}'));
    try {
      await channel.ready;
    } catch (error) {
      setState(() => this.channel = null);
      widget.leaveGame();
    }

    channel.stream.listen((data) => setState(() => game = Phrazzle.fromJsonString(data)));

    channel.sink.done.whenComplete(() {
      setState(() => this.channel = null);
      widget.leaveGame();
    });

    setState(() => this.channel = channel);
  }

  void disconnect() {
    channel?.sink.close(1000);
    setState(() => channel = null);
    widget.leaveGame();
  }

  void getUsers() async {
    for (final playerId in game.players) {
      if (playerUsers.containsKey(playerId)) continue;
      final userResponse = await http.get(Uri.parse('${Env.centralUrl}/player/$playerId/user'));
      final user = User.fromJsonString(userResponse.body);
      setState(() => playerUsers[playerId] = user);
    }
  }

  void startGame() {

  }

  void startRound(String phrase) {

  }

  void enterPhrase(String phrase) {

  }

  void endRound() {

  }

  @override
  void initState() {
    super.initState();
    connect();
    getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(child: Game(widget.playerId, game, playerUsers, startGame: startGame, leaveGame: disconnect, startRound: startRound, enterPhrase: enterPhrase, endRound: endRound)),
        if (game.isStarted) Column(children: [
          Text('Game code'),
          Text(gameCode)
        ],)
      ],
    );
  }
}