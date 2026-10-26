import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/device_store.dart';
import 'package:phrazzle/env.dart';
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
  User user = User.blank();
  var showLocalGame = false;
  var hadConnectionError = false;

  void skipLogin() => setState(() => widget.deviceStore.skipLogin = true);

  void editUser(User user) async {
    User newUser;
    if (widget.deviceStore.userId == null) {
      final response = await http.post(
        Uri.parse('${Env.centralUrl}/users'), body: User.info(user.name).jsonString
      );
      newUser = User.fromJsonString(response.body);
    } else {
      final response = await http.put(
        Uri.parse('${Env.centralUrl}/users'), body: User(widget.deviceStore.userId!, user.name).jsonString
      );
      newUser = User.fromJsonString(response.body);
    }
    widget.deviceStore.userId = newUser.id;
    setState(() => this.user = newUser);
  }

  void getUser() async {
    if (widget.deviceStore.userId == null) return;
    try {
      final response = await http.get(Uri.parse('${Env.centralUrl}/users/${widget.deviceStore.userId}'));
      if (response.statusCode == 404) {
        setState(() {
          widget.deviceStore.userId = null;
          user = User.blank();
        });
        return;
      }
      setState(() => user = User.fromJsonString(response.body));
    } on SocketException {
      setState(() {
        user = User.blank();
        hadConnectionError = true;
      });
    }
  }

  void startLocalGame() {
    setState(() => showLocalGame = true);
  }

  void leaveGame() {
    setState(() => showLocalGame = false);
  }

  @override
  void initState() {
    super.initState();
    if (user.id.isEmpty) getUser();
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;

    if (user.id.isEmpty && widget.deviceStore.skipLogin == false && hadConnectionError == false) {
      return Login(editUser, skipLogin);
    }

    if (showLocalGame) return LocalGame(user, leaveGame);

    return MainMenu(user, startLocalGame: startLocalGame,);
  }
}