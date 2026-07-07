import 'package:phrazzle_lib/phrazzle.dart';
import 'dart:io';

void main(List<String> arguments) {
  final game = Phrazzle();
  String? input;

  // Register players
  var playerIndex = 1;
  print('Enter player names (leave empty to finish)\n---');
  do {
    print('Player $playerIndex:');
    input = stdin.readLineSync();
    if (input!.isNotEmpty) {
      game.addPlayer(input);
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

  // Start game and create a round
  game.start();
  final round = Round(startingPhrase, game.players.values.toList());

  // Player turn loop
  for (final player in game.players.values) {
    var phraseIndex = 1;

    // Get player phrase entries
    print('Player: ${player.name}');
    do {
      print('Entry: $phraseIndex');
      input = stdin.readLineSync();
      if (input!.isNotEmpty) {
        round.addPlayerSubPhrase(player, input);
        phraseIndex++;
      }
    } while (input.isNotEmpty);
  }

  // Score round
  round.scoreRound();

  // Display winning player(s)
  final winnerIds = game.end();
  final winningPlayers = game.players.entries.where(
    (final playerEntry) => winnerIds.contains(playerEntry.key),
  );

  print('Winner(s):');
  for (final player in winningPlayers) {
    print('Player: ${player.value.name}');
    print('Score: ${player.value.score}');
    print('\n');
  }
}
