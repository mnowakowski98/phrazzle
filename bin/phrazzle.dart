import 'package:phrazzle/phrazzle.dart';
import 'dart:io';

class Player {
  String id;
  String name;
  int? score;

  Player(this.id, this.name);
}

void main(List<String> arguments) {
  final game = Phrazzle();
  String? line;
  final players = <Player>[];

  do {
    print('Enter player name: \n');
    line = stdin.readLineSync();
    if (line != null) players.add(Player(game.addPlayer(), line));
  } while (line != null);

  final rootPhrase = stdin.readLineSync();
  if (rootPhrase == null) throw Error();

  for (final player in players) {
    String? subPhraseLine;
    var phraseIndex = 0;
    final subPhrases = <String>[];

    print('Player: ${player.name}\n');
    do {
      print('Phrase #: $phraseIndex\n');
      subPhraseLine = stdin.readLineSync();
      if (subPhraseLine != null) subPhrases.add(subPhraseLine);
    } while (subPhraseLine != null);

    player.score = game.getScore(player.id);
  }

  final winners = game.end().fold(
    '',
    (final accum, final player) => '$accum:$player',
  );
  print(winners);
}
