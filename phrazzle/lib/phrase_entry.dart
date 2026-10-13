import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/env.dart';

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
  
  List<String> get playerPhrases => widget.round.subPhrases[widget.playerId]!;
  String get currentRootPhrase => playerPhrases.isEmpty ? widget.round.initialPhrase : playerPhrases.last;
  bool get isValidPhrase => PhrazzleBase.isValidSubPhrase(currentRootPhrase, phrase);

  final _phraseController = TextEditingController();

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  void submitPhrase() async {
    await http.post(
      Uri.parse('${Env.centralUrl}/game/phrase/${widget.playerId}/$phrase'),
    );
    setState(() => _phraseController.clear());
  }

  @override
  Widget build(BuildContext context) {
    const lastPhraseTextStyle = TextStyle(fontSize: 40, color: Colors.teal);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Focus(
                child: TextField(
                  controller: _phraseController,
                  style: TextStyle(color: isValidPhrase ? Colors.green : Colors.red),
                  decoration: InputDecoration(
                    labelText: 'Enter next phrase',
                    hintText: currentRootPhrase,
                    hintStyle: TextStyle(color: Colors.teal)
                  ),
                  onChanged: (value) => setState(() => phrase = value),
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) => newValue.text.length <= currentRootPhrase.length ? newValue : oldValue)
                  ],
                  
                ),
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent || event.logicalKey != .enter) {
                    return .ignored;
                  }
                  if (isValidPhrase) submitPhrase();
                  return .handled;
                },
              ),
            ),
            TextButton(
              onPressed: isValidPhrase ? submitPhrase : null,
              child: Text('Enter'),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              for (final phrase in playerPhrases.reversed)
                ListTile(title: Text(phrase), titleTextStyle: phrase == playerPhrases.last ? lastPhraseTextStyle : null,),
              ListTile(title: Text(widget.round.initialPhrase), titleTextStyle: playerPhrases.isEmpty ? lastPhraseTextStyle : null,),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            await http.delete(Uri.parse('${Env.centralUrl}/game'));
          },
          child: Text('Done'),
        ),
      ],
    );
  }
}
