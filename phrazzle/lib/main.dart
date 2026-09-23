import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'game.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Phrazzle'),
          actions: [
            TextButton(
              onPressed: () async {
                http.post(Uri.parse('http://localhost:3000/game'));
              },
              child: Text('Reset game'),
            ),
          ],
        ),
        body: Padding(padding: EdgeInsets.all(8.0), child: Game()),
      ),
    );
  }
}
