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

  print('Players\n---');
  print('${game.playerNames}\n');

  // Get starting phrase
  late final String startingPhrase;
  do {
    print('Enter starting phrase:');
    input = stdin.readLineSync();
    if (input!.isNotEmpty) startingPhrase = input;
  } while (input.isEmpty);

  // Start game and create a round
  game.start();
  final round = Round(startingPhrase, game.playerIds);

  // Player turn loop
  for (final playerEntry in game.players.entries) {
    var phraseIndex = 1;

    // Get player phrase entries
    print('Player: ${playerEntry.value.name}\n---');
    do {
      print('Entry: $phraseIndex');
      input = stdin.readLineSync();
      if (input!.isNotEmpty) {
        round.addPlayerSubPhrase(playerEntry.key, input);
        phraseIndex++;
      }
    } while (input.isNotEmpty);
  }

  // Score round
  final scores = round.scoreRound();
  game.incrementScores(scores);

  // Display winning player(s)
  final winnerIds = game.end();
  final winningPlayers = game.players.entries
      .where((final playerEntry) => winnerIds.contains(playerEntry.key))
      .map((player) => player.value);

  print('Winner(s):');
  for (final player in winningPlayers) {
    print('Player: ${player.name}');
    print('Score: ${player.score}');
    print('\n');
  }
}
