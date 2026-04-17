import 'package:flutter/material.dart';

class PlayerEntries extends StatelessWidget {
  final List<String> entries;

  const PlayerEntries(this.entries, {super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [for (final entry in entries) ListTile(title: Text(entry))],
      ),
    );
  }
}
