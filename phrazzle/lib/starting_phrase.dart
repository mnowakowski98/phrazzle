import 'package:flutter/material.dart';

class StartingPhrase extends StatefulWidget {
  final void Function(String phrase) onPhraseSet;

  const StartingPhrase(this.onPhraseSet, {super.key});

  @override
  State<StatefulWidget> createState() => _StartingPhraseState();
}

class _StartingPhraseState extends State<StartingPhrase> {
  var inputText = '';

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Set the starting phrase'),
        Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (final text) => setState(() => inputText = text),
              ),
            ),
            TextButton(
              onPressed: () => widget.onPhraseSet(inputText),
              child: Text('Set'),
            ),
          ],
        ),
      ],
    );
  }
}
