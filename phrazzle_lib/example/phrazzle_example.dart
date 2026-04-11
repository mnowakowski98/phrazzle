import 'package:phrazzle_lib/phrazzle.dart';
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
    print('Enter player name:');
    line = stdin.readLineSync();
    if (line!.isNotEmpty) players.add(Player(game.addPlayer(), line));
  } while (line.isNotEmpty);

  print('Root phrase:');
  final rootPhrase = stdin.readLineSync();
  if (rootPhrase == null) throw Error();

  for (final player in players) {
    String? subPhraseLine;
    var phraseIndex = 0;
    final subPhrases = <String>[];

    print('Player: ${player.name}');
    do {
      print('Phrase #: $phraseIndex');
      subPhraseLine = stdin.readLineSync();
      if (subPhraseLine!.isNotEmpty) {
        subPhrases.add(subPhraseLine);
        phraseIndex++;
      }
    } while (subPhraseLine.isNotEmpty);

    game.incrementScore(
      player.id,
      Phrazzle.scorePhrases(rootPhrase, subPhrases),
    );
    player.score = game.getScore(player.id);
  }

  final winnerIds = game.end();
  final winningPlayers = players.where(
    (final player) => winnerIds.contains(player.id),
  );

  print('Winner(s):');
  for (final player in winningPlayers) {
    print('Player: ${player.name}');
    print('Score: ${player.score}');
    print('\n');
  }
}
