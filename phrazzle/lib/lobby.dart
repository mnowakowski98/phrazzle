import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatefulWidget {
  final Phrazzle game;

  const Lobby(this.game, {super.key});

  @override
  State<Lobby> createState() => _LobbyState();
}

class _LobbyState extends State<Lobby> {
  final startingPhraseController = TextEditingController();
  var allowPhraseEntry = false;

  @override
  void initState() {
    super.initState();
    startingPhraseController.addListener(() {
      setState(
        () => allowPhraseEntry = startingPhraseController.text.isNotEmpty,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerList(widget.game.players.values.toList()),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: startingPhraseController,
                decoration: InputDecoration(hintText: 'Starting phrase'),
              ),
            ),
            TextButton(
              onPressed: allowPhraseEntry
                  ? () async {
                      // TODO: Remove hardcoded url
                      await http.put(
                        Uri.parse(
                          'http://localhost:3000/game/${startingPhraseController.text}',
                        ),
                      );
                    }
                  : null,
              child: Text('Start'),
            ),
          ],
        ),
      ],
    );
  }
}
