import 'package:flutter/material.dart';
import 'package:phrazzle/entered_texts.dart';

void main() {
  runApp(const MainApp());
}

class _MainAppState extends State<MainApp> {
  final List<String> texts = ['test'];
  String textToAdd = '';

  void addText(String text) {
    setState(() {
      texts.add(text);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Padding(
          padding: EdgeInsets.all(8.0),
          child: Column(
            children: [
              TextField(
                onChanged: (final text) {
                  setState(() {
                    textToAdd = text;
                  });
                },
              ),
              TextButton(
                onPressed: () => addText(textToAdd),
                child: Text('Add'),
              ),
              Expanded(child: EnteredTexts(texts)),
            ],
          ),
        ),
      ),
    );
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<StatefulWidget> createState() => _MainAppState();
}
