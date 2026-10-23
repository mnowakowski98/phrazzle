import 'package:flutter/material.dart';
import 'package:phrazzle/device_store.dart';
import 'package:phrazzle/main_menu.dart';

class App extends StatefulWidget {
  final DeviceStore deviceStore;

  const App(this.deviceStore, {super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MainMenu('');
  }
}