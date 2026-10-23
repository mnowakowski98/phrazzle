import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:phrazzle/connected_game.dart';
import 'package:phrazzle/env.dart';
import 'package:phrazzle/main_menu.dart';
import 'package:phrazzle/phrase_entry.dart';
import 'package:phrazzle/scores.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/lobby.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Game extends StatefulWidget {
  final SharedPreferencesWithCache deviceCache;
  final String deviceId;
  final String instanceId;

  const Game(this.deviceCache, this.deviceId, this.instanceId, {super.key});

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  WebSocketChannel? channel;
  String? connectedGameId;
  String? connectedPlayerId;

  Phrazzle? game;
  Round? round;

  static const lastGameIdKey = 'LAST_GAME_ID';
  static const lastPlayerIdKey = 'LAST_PLAYER_ID';

  String? get lastGameId => widget.deviceCache.getString(lastGameIdKey);
  String? get lastPlayerId => widget.deviceCache.getString(lastPlayerIdKey);

  var displayName = '';

  void connect(String gameId, String playerId) async {
    connectedGameId = gameId;
    connectedPlayerId = playerId;

    widget.deviceCache.setString(lastGameIdKey, gameId);
    widget.deviceCache.setString(lastPlayerIdKey, playerId);

    channel = WebSocketChannel.connect(Uri.parse('${Env.gameUrl}/game/$gameId/$playerId'));

    try {
      await channel!.ready;
    }
    catch (error) {
      widget.deviceCache.remove(lastGameIdKey);
      widget.deviceCache.remove(lastPlayerIdKey);

      setState(() {
        connectedGameId = null;
        connectedPlayerId = null;
        game = null;
        round = null;
        channel = null;
      });
      return;
    }

    channel!.sink.done.whenComplete(() {
      if (channel?.closeCode == 1000) {
        widget.deviceCache.remove(lastGameIdKey);
        widget.deviceCache.remove(lastPlayerIdKey);

        setState(() {
          connectedGameId = null;
          connectedPlayerId = null;
          game = null;
          round = null;
          channel = null;
        });
      } else {
        if (connectedGameId == null || connectedPlayerId == null) return;
        Timer(const Duration(seconds: 2), () => connect(connectedGameId!, connectedPlayerId!));
      }
    });

    channel!.sink.add(jsonEncode({'deviceId': widget.deviceId, 'instanceId': widget.instanceId}));

    channel!.stream.listen((data) {
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
  }

  void disconnect() async {
    channel?.sink.close(1000);
    widget.deviceCache.remove(lastGameIdKey);
    widget.deviceCache.remove(lastPlayerIdKey);

    setState(() {
      connectedGameId = null;
      connectedPlayerId = null;
      game = null;
      round = null;
      channel = null;
    });
  }

  void createGame(String playerName) async {
    if (playerName.isEmpty) return;
    setState(() => displayName = playerName);

    final createResponse = await http.post(Uri.parse('${Env.centralUrl}/game'));
    final newGameId = createResponse.body;
    final addPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$newGameId/$playerName'));
    connect(newGameId, addPlayerResponse.body);
  }

  void joinGame(String playerName, String gameCode) async {
    if (playerName.isEmpty || gameCode.isEmpty) return;
    setState(() => displayName = playerName);

    final gameIdResponse = await http.get(Uri.parse('${Env.centralUrl}/game/$gameCode'));
    final gameId = gameIdResponse.body;
    final addPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$gameId/$playerName'));
    connect(gameId, addPlayerResponse.body);
  }

  @override
  void initState() {
    super.initState();
    if (lastGameId != null && lastPlayerId != null) connect(lastGameId!, lastPlayerId!);
  }

  @override
  void dispose() {
    channel?.sink.close(1000);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (connectedPlayerId == null) {
      return MainMenu(displayName, createGame: createGame, joinGame: joinGame);
    }
    else if (game?.isStarted == false && game?.isEnded == false) {
      return Lobby(ConnectedGame(connectedGameId!, connectedPlayerId!, game!));
    }
    else if (game?.isStarted == true && game?.isEnded == false && round != null) {
      return PhraseEntry(ConnectedGame(connectedGameId!, connectedPlayerId!, game!, round!));
    }
    else if (game?.isStarted == true && game?.isEnded == true) {
      return Scores(ConnectedGame(connectedGameId!, connectedPlayerId!, game!, round!), disconnect);
    }

    return Placeholder();
  }
}
