import 'package:flutter/material.dart';
import 'package:phrazzle/device_store.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'game.dart';

void main() async {
  final preferences = await SharedPreferencesWithCache.create(cacheOptions: SharedPreferencesWithCacheOptions());
  final deviceStore = DeviceStore(preferences);
  runApp(MainApp(deviceStore));
}

class MainApp extends StatelessWidget {
  final DeviceStore deviceStore;

  const MainApp(this.deviceStore, {super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.cyan,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Phrazzle'),
        ),
        body: Padding(padding: EdgeInsets.all(8.0), child: Game(deviceStore)),
      ),
    );
  }
}
