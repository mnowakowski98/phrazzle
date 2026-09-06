import 'package:flutter/widgets.dart';
import 'package:phrazzle/player_list.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Lobby extends StatelessWidget {
  final Phrazzle game;

  const Lobby(this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return PlayerList(game.players.values.toList(), '');
  }
}
