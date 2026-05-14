import 'package:flutter/material.dart';

class PlayerEntries extends StatefulWidget {
  final void Function(List<String> entries) onEnd;

  const PlayerEntries(this.onEnd, {super.key});

  @override
  State<PlayerEntries> createState() => _PlayerEntriesState();
}

class _PlayerEntriesState extends State<PlayerEntries> {
  final entries = <String>[];
  var inputText = '';

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            title: Text('Derived phrases'),
            subtitle: Row(
              children: [
                TextField(
                  onChanged: (final text) => setState(() => inputText = text),
                ),
                TextButton(
                  onPressed: () => setState(() => entries.add(inputText)),
                  child: Text('Enter'),
                ),
                TextButton(
                  onPressed: () => widget.onEnd(entries),
                  child: Text('Done'),
                ),
              ],
            ),
          ),
          for (final entry in entries) ListTile(title: Text(entry)),
        ],
      ),
    );
  }
}
