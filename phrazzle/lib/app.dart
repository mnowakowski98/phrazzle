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

  User? user;
  Iterable<User> get storedUsers => widget.deviceStore.users;

  void skipLogin() => setState(() => user = User.anonymous());

  void createUser(User user) async {
    if (user.isInfo == false) return;

    final response = await http.post(
      Uri.parse('${Env.centralUrl}/user'), body: User.info(user.name).jsonString
    );

    final centralUser = User.fromJsonString(response.body);
    setState(() {
      this.user = centralUser;
      widget.deviceStore.storeUser(centralUser);
      widget.deviceStore.lastUserId = centralUser.id;
    });
  }

  void login(User user) async {
    if (user.isAnonymous) {
      setState(() => this.user = user);
      return;
    }
    if (user.isUser == false) return;

    final response = await http.get(
      Uri.parse('${Env.centralUrl}/user/${user.id}'),
    );

    if (response.statusCode == 404) {
      setState(() => widget.deviceStore.removeUser(user.id));
      return;
    }

    final centralUser = User.fromJsonString(response.body);
    setState(() {
      this.user = centralUser;
      widget.deviceStore.storeUser(centralUser);
    });
  }

  void logout() {
    final user = this.user ?? User.anonymous();
    if (user.isUser == true) widget.deviceStore.storeUser(user);
    setState(() => this.user = null);
  }
  
  bool get allowOnline => serviceHealthy == true && user?.isUser == true;

  var showLocalGame = false;

  String? connectedGameId;
  String? connectedPlayerId;

  void startLocalGame() {
    setState(() => showLocalGame = true);
  }

  void startConnectedGame() async {
    final user = this.user;
    if (user == null) return;

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
    final user = this.user;
    if (user == null) return;

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
    var user = this.user;
    Widget displayWidget = Login(storedUsers, onCreateUser: createUser, onLogin: login);

    if (serviceHealthy == false) user = User.anonymous();

    if (showLocalGame) {
      displayWidget = LocalGame(user ?? User.anonymous(), leaveGame);
    }

    if (user != null) {
      displayWidget = MainMenu(
        user,
        startLocalGame: startLocalGame,
        startConnectedGame: startConnectedGame,
        joinConnectedGame: joinConnectedGame,
        logout: logout,
      );

      final connectedGameId = this.connectedGameId;
      final connectedPlayerId = this.connectedPlayerId;
      if (connectedGameId != null &&
          connectedPlayerId != null) {
        displayWidget = ConnectedGame(
          connectedGameId,
          connectedPlayerId,
          user,
          leaveGame,
        );
      }
    }

    if (serviceHealthy == false) {
      return Center(
        child: Column(
          children: [
            Text('Unable to connect to central service', style: TextStyle(color: Colors.red),),
            TextButton(onPressed: pollServiceHealth, child: Text('Retry')),
            Expanded(child: displayWidget),
          ],
        ),
      );
    }

    return displayWidget;
  }
}