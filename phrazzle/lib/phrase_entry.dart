import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/connected_game.dart';
import 'package:phrazzle/env.dart';
import 'package:phrazzle_lib/phrazzle.dart';


class PhraseEntry extends StatefulWidget {
  final ConnectedGame connectedGame;

  const PhraseEntry(this.connectedGame, {super.key});

  @override
  State<PhraseEntry> createState() => _PhraseEntryState();
}

class _PhraseEntryState extends State<PhraseEntry> {
  String phrase = '';

  List<String> get playerPhrases => widget.connectedGame.round!.phrases[widget.connectedGame.playerId]!;
  String get currentRootPhrase => playerPhrases.isEmpty ? widget.connectedGame.round!.initialPhrase : playerPhrases.last;
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
      Uri.parse('${Env.centralUrl}/game/phrase/${widget.connectedGame.gameId}/${widget.connectedGame.playerId}/$phrase'),
    );
    _phraseController.clear();
  }

  void endEntry() async {
    await http.put(Uri.parse('${Env.centralUrl}/game/${widget.connectedGame.gameId}/${widget.connectedGame.playerId}/done'));
    _phraseController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final phrases = [for (final phrase in playerPhrases.reversed) phrase, widget.connectedGame.round!.initialPhrase];

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
              onPressed: (widget.connectedGame.round!.phraseLocks[widget.connectedGame.playerId] == false && phraseInfo.isValid == true) ? submitPhrase : null,
              child: Text('Enter'),
            ),
          ],
        ),
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
        if (widget.connectedGame.round!.phraseLocks[widget.connectedGame.playerId] == false) TextButton(onPressed: phrase.isEmpty ? endEntry : null, child: Text('Done')),
        Divider(),
        Text(widget.connectedGame.round!.unlockedPhrases > 1 ? 'Waiting on players' : 'Waiting on player', style: TextStyle(fontSize: 16),),
        if (widget.connectedGame.round!.unlockedPhrases <= 2) Row(
          mainAxisAlignment: .center,
          spacing: 10,
          children: [
            for (final playerName in widget.connectedGame.round!.unlockedPhraseIds.map((id) => widget.connectedGame.game.players[id]!.name))
              Text(playerName, style: TextStyle(fontSize: 18, color: Colors.cyan))
          ]
        ),
        if (widget.connectedGame.round!.unlockedPhrases >= 3) Text(widget.connectedGame.round!.unlockedPhrases.toString(), style: TextStyle(fontSize: 18, color: Colors.teal),),
        Divider(),
      ],
    );
  }
}
