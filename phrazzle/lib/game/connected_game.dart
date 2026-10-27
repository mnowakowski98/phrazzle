import 'package:flutter/material.dart';
import 'package:phrazzle/env.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/game/game.dart';
import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle, User;

class ConnectedGame extends StatefulWidget {
  final String gameId;
  final String playerId;
  final User user;
  final void Function() leaveGame;

  const ConnectedGame(
    this.gameId,
    this.playerId,
    this.user,
    this.leaveGame, {
    super.key,
  });

  @override
  State<ConnectedGame> createState() => _ConnectedGameState();
}

class _ConnectedGameState extends State<ConnectedGame> {
  final Phrazzle game = Phrazzle();
  WebSocketChannel? channel;

  void connect() async {
    final channel = WebSocketChannel.connect(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/${widget.playerId}'));
    try {
      await channel.ready;
    } catch (error) {
      setState(() => this.channel = null);
    }

    channel.sink.done.whenComplete(() {
      setState(() => this.channel = null);
    });

    setState(() => this.channel = channel);
  }

  void disconnect() {
    channel?.sink.close(1000);
    setState(() => channel = null);
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
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}