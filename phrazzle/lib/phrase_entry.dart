import 'package:flutter/material.dart';
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
  final phraseController = TextEditingController();
  var allowPhraseEntry = false;

  @override
  void initState() {
    super.initState();
    phraseController.addListener(() {
      setState(() => allowPhraseEntry = phraseController.text.isNotEmpty);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: widget.round.initialPhrase,
                ),
                controller: phraseController,
              ),
            ),
            TextButton(
              onPressed: allowPhraseEntry
                  ? () async {
                      await http.post(
                        Uri.parse(
                          'http://localhost:3000/game/phrase/${widget.playerId}/${phraseController.text}',
                        ),
                      );
                    }
                  : null,
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
      ],
    );
  }
}
