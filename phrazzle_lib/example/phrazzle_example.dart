import 'package:phrazzle_lib/phrazzle.dart';
import 'dart:io';

/// Display info for players
class Player {
  String id;
  String name;
  int? score;

  Player(this.id, this.name);
}

void main(List<String> arguments) {
  final game = Phrazzle();
  String? input;

  // Register players
  final players = <Player>[];
  var playerIndex = 1;
  print('Enter player names (leave empty to finish)\n---');
  do {
    print('Player $playerIndex:');
    input = stdin.readLineSync();
    if (input!.isNotEmpty) {
      players.add(Player(game.addPlayer(), input));
      playerIndex++;
    }
  } while (input.isNotEmpty);

  // Get starting phrase
  late final String startingPhrase;
  do {
    print('Enter starting phrase:');
    input = stdin.readLineSync();
    if (input!.isNotEmpty) startingPhrase = input;
  } while (input.isEmpty);

  // Player turn loop
  game.start();
  for (final player in players) {
    final subPhrases = <String>[];
    var phraseIndex = 1;

    // Get player phrase entries
    print('Player: ${player.name}');
    do {
      print('Entry: $phraseIndex');
      input = stdin.readLineSync();
      if (input!.isNotEmpty) {
        subPhrases.add(input);
        phraseIndex++;
      }
    } while (input.isNotEmpty);

    // Calculate score
    game.incrementScore(
      player.id,
      Phrazzle.scorePhrases(startingPhrase, subPhrases),
    );
    player.score = game.getScore(player.id);
  }

  // Display winning player(s)
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
