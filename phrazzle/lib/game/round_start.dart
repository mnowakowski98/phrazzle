import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class RoundStart extends StatefulWidget {
  final void Function(String phrase) onStart;

  const RoundStart(this.onStart, {super.key});

  @override
  State<RoundStart> createState() => _RoundStartState();
}

class _RoundStartState extends State<RoundStart> {
  var initialPhrase = '';
  final _initialPhraseController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initialPhraseController.addListener(() => setState(() => initialPhrase = _initialPhraseController.text));
  }

  @override
  void dispose() {
    _initialPhraseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: .start, children: [
      Text('New round', style: TextStyle(color: Colors.teal, fontSize: 24)),
      Column(
        crossAxisAlignment: .center,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
              child: Focus(
                onKeyEvent: (node, event) {
                  if (event is KeyUpEvent || event.logicalKey != .enter) {
                    return .ignored;
                  }
                  if (initialPhrase.isNotEmpty) widget.onStart(initialPhrase);
                  return .handled;
                },
                child: TextField(
                  controller: _initialPhraseController,
                  decoration: InputDecoration(hintText: 'Round phrase'),
                ),
              ),
          ),
          Divider(),
          ElevatedButton(onPressed: initialPhrase.isNotEmpty ? () => widget.onStart(initialPhrase) : null, child: Text('Start')),
        ],
      ),
      Divider()
    ],);
  }
}