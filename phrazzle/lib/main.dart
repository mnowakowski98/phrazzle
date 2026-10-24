import 'package:flutter/material.dart';
import 'package:phrazzle/app.dart';
import 'package:phrazzle/device_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  final preferences = await SharedPreferencesWithCache.create(cacheOptions: SharedPreferencesWithCacheOptions());
  final deviceStore = DeviceStorage(preferences);
  runApp(MainApp(deviceStore));
}

class MainApp extends StatelessWidget {
  final DeviceStorage deviceStore;

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
        body: Padding(padding: EdgeInsets.all(8.0), child: App(deviceStore)),
      ),
    );
  }
}
