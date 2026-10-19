import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import 'game.dart';

void main() async {
  final prefs = await SharedPreferencesWithCache.create(cacheOptions: SharedPreferencesWithCacheOptions());
  var deviceId = prefs.getString('DEVICE_ID');
  if (deviceId == null) {
    deviceId = Uuid().v4();
    prefs.setString('DEVICE_ID', deviceId);
  }
  
  runApp(MainApp(prefs, deviceId, Uuid().v4()));
}

class MainApp extends StatelessWidget {
  final SharedPreferencesWithCache deviceCache;
  final String deviceId;
  final String instanceId;

  const MainApp(this.deviceCache, this.deviceId, this.instanceId, {super.key});

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
        body: Padding(padding: EdgeInsets.all(8.0), child: Game(deviceCache, deviceId, instanceId)),
      ),
    );
  }
}
