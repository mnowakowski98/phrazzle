import 'package:flutter/material.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class PhraseEntry extends StatefulWidget {
  final Round round;

  const PhraseEntry(this.round, {super.key});

  @override
  State<PhraseEntry> createState() => _PhraseEntryState();
}

class _PhraseEntryState extends State<PhraseEntry> {
  final phraseController = TextEditingController();

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
              onPressed: phraseController.text.isNotEmpty ? () {} : null,
              child: Text('Enter'),
            ),
          ],
        ),
      ],
    );
  }
}
