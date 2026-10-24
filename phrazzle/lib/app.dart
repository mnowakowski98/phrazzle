import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/device_store.dart';
import 'package:phrazzle/env.dart';
import 'package:phrazzle/main_menu.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class App extends StatefulWidget {
  final DeviceStorage deviceStore;

  const App(this.deviceStore, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  User? user;

  var editingPlayerName = false;
  var playerNameText = '';
  final _nameController = TextEditingController();

  void editUser() async {
    User newUser;
    if (widget.deviceStore.userId == null) {
      final response = await http.post(
        Uri.parse('${Env.centralUrl}/users'), body: User.info(playerNameText).jsonString
      );
      newUser = User.fromJsonString(response.body);
    } else {
      final response = await http.put(
        Uri.parse('${Env.centralUrl}/users'), body: User(widget.deviceStore.userId!, playerNameText).jsonString
      );
      newUser = User.fromJsonString(response.body);
    }
    widget.deviceStore.userId = newUser.id;
    setState(() => user = newUser);
  }

  void getUser() async {
    if (widget.deviceStore.userId == null) return;
    final response = await http.get(Uri.parse('${Env.centralUrl}/users/${widget.deviceStore.userId}'));
    if (response.statusCode == 404) {
      widget.deviceStore.userId = null;
      setState(() => user = null);
      return;
    }
    setState(() => user = User.fromJsonString(response.body));
  }

  @override
  void initState() {
    super.initState();
    if (user == null) getUser();
    _nameController.addListener(() => setState(() => playerNameText = _nameController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = this.user;

    if (user == null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(controller: _nameController, decoration: InputDecoration(hintText: 'Display name')),
          ),
          ElevatedButton(onPressed: editUser, child: Text('Start')),
        ],
      );
    }

    return Column(
      crossAxisAlignment: .center,
      children: [
        Text(user.name, style: TextStyle(color: Colors.teal, fontSize: 24)),
        Divider(),
        MainMenu(),
      ],
    );
  }
}