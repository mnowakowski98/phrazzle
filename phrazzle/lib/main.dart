import 'package:flutter/material.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'game.dart';

void main() {
  runApp(const MainApp());
}

final game = Phrazzle();

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(padding: EdgeInsets.all(8.0), child: Game()),
      ),
    );
  }
}
