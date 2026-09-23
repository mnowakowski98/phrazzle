import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle_lib/phrazzle.dart';

class PhraseEntry extends StatefulWidget {
  final Round round;
  final String playerId;

  const PhraseEntry(this.round, this.playerId, {super.key});

  @override
  State<PhraseEntry> createState() => _PhraseEntryState();
}

class _PhraseEntryState extends State<PhraseEntry> {
  String phrase = '';
  bool get allowPhraseSubmission => phrase.isNotEmpty;

  void submitPhrase() async {
    await http.post(
      Uri.parse('http://localhost:3000/game/phrase/${widget.playerId}/$phrase'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Focus(
                child: TextField(
                  decoration: InputDecoration(
                    hintText: widget.round.initialPhrase,
                  ),
                  onChanged: (value) => setState(() => phrase = value),
                ),
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent || event.logicalKey != .enter) {
                    return .ignored;
                  }
                  if (allowPhraseSubmission) submitPhrase();
                  return .handled;
                },
              ),
            ),
            TextButton(
              onPressed: allowPhraseSubmission ? submitPhrase : null,
              child: Text('Enter'),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              for (final phrase in widget.round.subPhrases[widget.playerId]!)
                ListTile(title: Text(phrase)),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            await http.delete(Uri.parse('http://localhost:3000/game'));
          },
          child: Text('Done'),
        ),
      ],
    );
  }
}
