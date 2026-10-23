import 'package:phrazzle_lib/phrazzle.dart';
import 'dart:io';

void main(List<String> arguments) {
  final game = Phrazzle();
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

  // Start game and create a round
  game.start();

  // Player turn loop
  final phraseGroups = <String, PhraseGroup>{};
  for (final playerId in game.players) {
    final phraseGroup = PhraseGroup(startingPhrase);
    phraseGroups[playerId] = phraseGroup;
    var phraseIndex = 1;

    // Get player phrase entries
    print('Player: ${playerNames[playerId]}\n---');
    do {
      print('Entry: $phraseIndex');
      input = stdin.readLineSync();
      if (input!.isNotEmpty) {
        phraseGroup.addPhrase(input);
        phraseIndex++;
      }
    } while (input.isNotEmpty);

    if (PhraseValidator.getChainValidationInfo(startingPhrase, phraseGroup.phrases).every((info) => info.isValid)) {
      print('Score: ${phraseGroup.phrases.length}');
    } else {
      print('Invalid phrase in chain');
    }
  }
}
