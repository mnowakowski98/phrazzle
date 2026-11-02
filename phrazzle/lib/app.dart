import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/device_store.dart';
import 'package:phrazzle/env.dart';
import 'package:phrazzle/game/connected_game.dart';
import 'package:phrazzle/game/local_game.dart';
import 'package:phrazzle/menu/login.dart';
import 'package:phrazzle/menu/main_menu.dart';
import 'package:phrazzle_lib/phrazzle.dart' show User;

class App extends StatefulWidget {
  final DeviceStorage deviceStore;

  const App(this.deviceStore, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  bool? serviceHealthy;
  void pollServiceHealth() async {
    try {
      final healthzResponse = await http.get(Uri.parse('${Env.centralUrl}/healthz'));
      final isHealthy = jsonDecode(healthzResponse.body)['status'] == 'healthy';
      setState(() => serviceHealthy = isHealthy);
    } on SocketException {
      setState(() => serviceHealthy = false);
    }
  }

  User user = User.blank();
  bool get isLoggedIn => user.isInfo == false && user.isAnonymous == false;

  void skipLogin() => setState(() => user = User.anonymous());

  void createUser(User user) async {
    final response = await http.post(
      Uri.parse('${Env.centralUrl}/user'), body: User.info(user.name).jsonString
    );
    setState(() => user = User.fromJsonString(response.body));
  }

  void login(BuildContext context, String userId) async {
    final response = await http.get(Uri.parse('${Env.centralUrl}/user/$userId'));
    if (response.statusCode == 404 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Login failed'),  behavior: .floating,));
      return;
    }
    final user = User.fromJsonString(response.body);
    setState(() => this.user = user);
  }

  void logout() => setState(() {
    user = User.blank();
  });
  
  bool get allowOnline => serviceHealthy == true && isLoggedIn;

  var showLocalGame = false;

  String? connectedGameId;
  String? connectedPlayerId;

  void startLocalGame() {
    setState(() => showLocalGame = true);
  }

  void startConnectedGame() async {
    final createGameResponse = await http.post(Uri.parse('${Env.centralUrl}/game'));
    final gameId = createGameResponse.body;
    final createPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$gameId/player/${user.id}'));
    final playerId = createPlayerResponse.body;

    setState(() {
      connectedGameId = gameId;
      connectedPlayerId = playerId;

      widget.deviceStore.lastGameId = connectedGameId;
      widget.deviceStore.lastPlayerId = playerId;
    });
  }

  void joinConnectedGame(String gameCode) async {
    final gameIdResponse = await http.get(Uri.parse('${Env.centralUrl}/game/$gameCode'));
    final gameId = gameIdResponse.body;
    final createPlayerResponse = await http.post(Uri.parse('${Env.centralUrl}/game/$gameId/player/${user.id}'));
    final playerId = createPlayerResponse.body;

    setState(() {
      connectedGameId = gameId;
      connectedPlayerId = playerId;

      widget.deviceStore.lastGameId = gameId;
      widget.deviceStore.lastPlayerId = playerId;
    });
  }

  void leaveGame() {
    setState(() {
      showLocalGame = false;
      connectedGameId = null;
      connectedPlayerId = null;

      widget.deviceStore.lastGameId = null;
      widget.deviceStore.lastPlayerId = null;
    });
  }

  @override
  void initState() {
    super.initState();
    pollServiceHealth();
    
    connectedGameId = widget.deviceStore.lastGameId;
    connectedPlayerId = widget.deviceStore.lastPlayerId;
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;

    Widget displayWidget = MainMenu(
      user,
      startLocalGame: startLocalGame,
      startConnectedGame: startConnectedGame,
      joinConnectedGame: joinConnectedGame,
      logout: logout,
    );

    if (user.isInfo) {
      displayWidget = Login((User user) => login(context, user.id), skipLogin);
    }

    if (showLocalGame) displayWidget = LocalGame(user, leaveGame);

    final connectedGameId = this.connectedGameId;
    final connectedPlayerId = this.connectedPlayerId;
    if (connectedGameId != null && connectedPlayerId != null) {
      displayWidget = ConnectedGame(connectedGameId, connectedPlayerId, user, leaveGame);
    }

    return Column(children: [
      if (serviceHealthy == false) Column(
        children: [
          Divider(),
          Row(mainAxisAlignment: .center, spacing: 5, children: [
            Text('Unable to connect to central service', style: TextStyle(color: Colors.red),),
            TextButton(onPressed: pollServiceHealth, child: Text('Retry'))
          ],),
          Divider(),
        ],
      ),
      Expanded(child: displayWidget),
    ],);
  }
}