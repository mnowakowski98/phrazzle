import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class PhraseEntry extends StatefulWidget {
  final String playerId;
  final Round round;

  final void Function(String phrase) onEntry; 
  final void Function() onEntryEnd;

  const PhraseEntry(
    this.playerId,
    this.round,
    this.onEntry,
    this.onEntryEnd, {
    super.key,
  });

  @override
  State<PhraseEntry> createState() => _PhraseEntryState();
}

class _PhraseEntryState extends State<PhraseEntry> {
  var phrase = '';
  final _phraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _phraseController.addListener(() => phrase = _phraseController.text);
  }

  @override
  void dispose() {
    _phraseController.dispose();
    super.dispose();
  }

  void submitPhrase(String phrase, PhraseValidationInfo phraseInfo) {
    if (phraseInfo.isValid == false) return;
    widget.onEntry(phrase);
    _phraseController.clear();
  }

  void endEntry() {
    widget.onEntryEnd();
    _phraseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final phraseGroup = widget.round.phraseGroups[widget.playerId]!;
    final phrases = [for (final phrase in phraseGroup.phrases.toList().reversed) phrase, phraseGroup.initialPhrase];
    final rootPhrase = phraseGroup.phrases.isEmpty ? phraseGroup.initialPhrase : phraseGroup.phrases.last;
    final phraseInfo = PhraseValidator.getPhraseMatchingInformation(rootPhrase, phrase);

    final showDoneButton = phraseGroup.isLocked == false && rootPhrase != phraseGroup.initialPhrase;

    final unlockedPhraseGroups = widget.round.phraseGroups.entries.where((entry) => entry.value.isLocked == false).map((entry) => entry.key);

    return Column(
      children: [
        if (phraseGroup.isLocked == false) Row(
          children: [
            Expanded(
              child: Focus(
                child: TextField(
                  controller: _phraseController,
                  style: TextStyle(color: phraseInfo.isValid ? Colors.green : Colors.red),
                  decoration: InputDecoration(
                    labelText: 'Enter next phrase',
                    hintStyle: TextStyle(color: Colors.teal)
                  ),
                  onChanged: (value) => setState(() => phrase = value),
                  inputFormatters: [
                    // TextInputFormatter.withFunction((oldValue, newValue) => newValue.text.length <= rootPhrase.length ? newValue : oldValue)
                  ],
                ),
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent || event.logicalKey != .enter) {
                    return .ignored;
                  }
                  submitPhrase(phrase, phraseInfo);
                  return .handled;
                },
              ),
            ),
            TextButton(
              onPressed: phrase.isNotEmpty ? () => submitPhrase(phrase, phraseInfo) : null,
              child: Text('Enter'),
            ),
          ],
        ),
        if (phraseGroup.isLocked) Text(phraseGroup.initialPhrase, style: TextStyle(color: Colors.cyan, fontSize: 24)),
        Expanded(
          child: ListView(
            children: [
              for (final phrase in phrases) phrase == phrases.first ?
                Text.rich(TextSpan(style: TextStyle(fontSize: 24), children: [
                  for (var phraseIndex = 0; phraseIndex < phrase.length; phraseIndex++) TextSpan(
                    text: phrase[phraseIndex],
                    style: (phraseInfo.matchIndices != null && phraseInfo.matchIndices!.contains(phraseIndex)) ? TextStyle(color: Colors.teal) : null,
                  )
                ])) : Text(phrase),
            ],
          ),
        ),
        if (showDoneButton) TextButton(onPressed: phrase.isEmpty ? endEntry : null, child: Text('Done')),
        if (phraseGroup.isLocked) Column(
          children: [
            Divider(),
            Text(unlockedPhraseGroups.length > 1 ? 'Waiting on players' : 'Waiting on player', style: TextStyle(fontSize: 16),),
            if (unlockedPhraseGroups.length <= 2) Row(
              mainAxisAlignment: .spaceAround,
              children: [
                // for (final playerName in widget.connectedGame.round!.unlockedPhraseIds.map((id) => widget.connectedGame.game.players[id]!.name))
                //   Text(playerName, style: TextStyle(fontSize: 18, color: Colors.cyan))
              ]
            ),
            if (unlockedPhraseGroups.length >= 3) Text(unlockedPhraseGroups.toString(), style: TextStyle(fontSize: 18, color: Colors.teal),),
            Divider(),
          ],
        ),
      ],
    );
  }
}
