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
  PhraseValidationInfo get phraseInfo => PhrazzleBase.getPhraseMatchingInformation(currentRootPhrase, phrase);

  final _phraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phraseController.addListener(() => setState(() => phrase = _phraseController.text));
  }

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  void submitPhrase() async {
    if (phraseInfo.isValid == false) return;
    await http.post(
      Uri.parse('${Env.centralUrl}/game/phrase/${widget.playerId}/$phrase'),
    );
    _phraseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    const lastPhraseTextStyle = TextStyle(color: Colors.teal);

    final phrases = [for (final phrase in playerPhrases.reversed) phrase, widget.round.initialPhrase];
    // final lastPhraseTextWidget = Text.rich(style: TextStyle(fontSize: 24), TextSpan(children: [for (var index = 0; index < text.length; index++) TextSpan(text: text[index], style: (phraseInfo.matchIndices != null && phraseInfo.matchIndices!.contains(index)) ? lastPhraseTextStyle : null)]));

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Focus(
                child: TextField(
                  controller: _phraseController,
                  style: TextStyle(color: phraseInfo.isValid ? Colors.green : Colors.red),
                  decoration: InputDecoration(
                    labelText: 'Enter next phrase',
                    // hintText: currentRootPhrase,
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
                  submitPhrase();
                  return .handled;
                },
              ),
            ),
            TextButton(
              onPressed: submitPhrase,
              child: Text('Enter'),
            ),
          ],
        ),
        Expanded(
          child: ListView(
            children: [
              for (final phrase in phrases) phrase == phrases.first ? Text.rich(TextSpan(style: TextStyle(fontSize: 24), children: [for (var phraseIndex = 0; phraseIndex < phrase.length; phraseIndex++) TextSpan(text: phrase[phraseIndex], style: (phraseInfo.matchIndices != null && phraseInfo.matchIndices!.contains(phraseIndex)) ? lastPhraseTextStyle : null)])) : Text(phrase),
            ],
          ),
        ),
        TextButton(
          onPressed: () async {
            await http.delete(Uri.parse('${Env.centralUrl}/game'));
          },
          child: Text('Done'),
        ),
        Row(mainAxisAlignment: .center, children: [
          Column(
            children: [
              Text(phraseInfo.matchIndices?.toString() ?? 'No match indices',),
              Text(phraseInfo.wholeWordMatch ?? 'No whole matches')
            ],
          ),
        ],),
      ],
    );
  }
}
