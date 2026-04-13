import 'package:flutter/material.dart';

class EnteredTexts extends StatelessWidget {
  final List<String> texts;
  const EnteredTexts(this.texts, {super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [for (final text in texts) ListTile(title: Text(text))],
    );
  }
}
