import 'package:flutter/material.dart';

class PhraseEntry extends StatefulWidget {
  const PhraseEntry({super.key});

  @override
  State<PhraseEntry> createState() => _PhraseEntryState();
}

class _PhraseEntryState extends State<PhraseEntry> {
  final _phraseController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Focus(child: TextField()),
      ],
    );
  }
}