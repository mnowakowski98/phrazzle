import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatelessWidget {
  final Phrazzle game;

  const Lobby(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PlayerList(game.players.values.toList()),
        TextButton(
          onPressed: () async {
            // TODO: Remove hardcoded url
            // TODO: Make start phrase user enterable
            await http.put(
              Uri.parse('http://localhost:3000/game/testingstartphrase'),
            );
          },
          child: Text('Start'),
        ),
      ],
    );
  }
}
