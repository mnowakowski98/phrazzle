import 'package:phrazzle_lib/phrazzle.dart';
import 'dart:io';

void main(List<String> arguments) {
  final game = Game();
  String? input;

  final playerNames = <String, String>{};

  // Register players
  var playerIndex = 1;
  print('Enter player names (leave empty to finish)\n---');
  do {
    print('Player $playerIndex:');
    input = stdin.readLineSync();
    if (input!.isNotEmpty) {
      final id = game.addPlayer();
      playerNames[id] = input;
      playerIndex++;
    }
  } while (input.isNotEmpty);

  print('Players\n---');
  print('${playerNames.values}\n');

  // Get starting phrase
  late final String startingPhrase;
  do {
    print('Enter starting phrase:');
    input = stdin.readLineSync();
    if (input!.isNotEmpty) startingPhrase = input;
  } while (input.isEmpty);

  // Create a roound and start the game
  final createRound = game.createRound(startingPhrase);
  final round = createRound.round;
  game.currentRoundId = createRound.id;
  game.start();

  // Player turn loop
  for (final playerId in game.players) {
    var phraseIndex = 1;

    // Get player phrase entries
    print('Player: ${playerNames[playerId]}\n---');
    do {
      print('Entry: $phraseIndex');
      input = stdin.readLineSync();
      if (input!.isNotEmpty) {
        game.addPhrase(playerId, input);
        phraseIndex++;
      }
    } while (input.isNotEmpty);

    final phraseGroup = round.phraseGroups[playerId]!;
    if (phraseGroup.isValidChain) {
      print('Score: ${round.scores[playerId]}');
    } else {
      print('Invalid phrase in chain');
    }
  }
}
