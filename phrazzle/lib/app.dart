import 'dart:convert';

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

  void login(User user, [bool setLastId = false, bool autoLogin = false]) async {
    if (setLastId) {
      setState(() {
        widget.deviceStore.lastUserId = user.id;
        widget.deviceStore.autoLogin = autoLogin;
      });
    }

    if (user.isAnonymous) {
      setState(() => this.user = user);
      return;
    }
    if (user.isUser == false) return;

    final response = await http.get(
      Uri.parse('${Env.centralUrl}/user/${user.id}'),
    );

    if (response.statusCode == 404) {
      setState(() {
        widget.deviceStore.lastUserId = null;
        widget.deviceStore.autoLogin = false;
        widget.deviceStore.removeUser(user.id);
      });
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

  bool? serviceHealthy;
  Future<bool> pollServiceHealth() async {
    var isHealthy = true;
    try {
      final healthResponse = await http.get(Uri.parse('${Env.centralUrl}/health'));
      if (healthResponse.statusCode == 200) {
        isHealthy = jsonDecode(healthResponse.body)['status'] == 'healthy';
      } else {
        isHealthy = false;
      }
    } catch (_) {
      isHealthy = false;
    }
    setState(() => serviceHealthy = isHealthy);
    return isHealthy;
  }

  var showLocalGame = false;
  void startLocalGame() {
    setState(() => showLocalGame = true);
  }
  
  bool get allowOnline => serviceHealthy == true && user?.isUser == true;

  String? connectedGameId;
  String? connectedPlayerId;

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

    final gameIdResponse = await http.get(Uri.parse('${Env.centralUrl}/game/code/$gameCode'));
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

  void startApp() async {
    bool isHealthy = await pollServiceHealth();
    if (isHealthy == false) {
      login(User.anonymous());
      return;
    }

    final autoLogin = widget.deviceStore.autoLogin;
    final lastUserId = widget.deviceStore.lastUserId;
    if (autoLogin && lastUserId != null) login(User.pending(lastUserId));
  }

  @override
  void initState() {
    super.initState();
    startApp();

    connectedGameId = widget.deviceStore.lastGameId;
    connectedPlayerId = widget.deviceStore.lastPlayerId;
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;
    Widget displayWidget = Login(
      widget.deviceStore.lastUserId,
      storedUsers,
      widget.deviceStore.autoLogin,
      onCreateUser: createUser,
      onLogin: (user, autoLogin) => login(user, true, autoLogin),
    );

    if (user != null) {
      displayWidget = MainMenu(
        user,
        startLocalGame: startLocalGame,
        startConnectedGame: startConnectedGame,
        joinConnectedGame: joinConnectedGame,
        logout: serviceHealthy == true ? logout : null,
      );

      final connectedGameId = this.connectedGameId;
      final connectedPlayerId = this.connectedPlayerId;
      if (connectedGameId != null && connectedPlayerId != null) {
        displayWidget = ConnectedGame(
          connectedGameId,
          connectedPlayerId,
          user,
          leaveGame,
        );
      }

      if (showLocalGame) {
        displayWidget = LocalGame(user, leaveGame);
      }
    }

    if (serviceHealthy == false) {
      return Center(
        child: Column(
          children: [
            Text(
              'Unable to connect to central service',
              style: TextStyle(color: Colors.red),
            ),
            TextButton(onPressed: startApp, child: Text('Retry')),
            Expanded(child: displayWidget),
          ],
        ),
      );
    }

    return displayWidget;
  }
}