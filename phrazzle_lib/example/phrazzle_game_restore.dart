import 'package:phrazzle_lib/phrazzle.dart';

void main() {
  final gameMap = <String, dynamic>{
    'players': {
      'testidlmao1': {'name': 'test player 1', 'score': 2},
      'testidlmao2': {'name': 'test player 2', 'score': 1},
    },
    'isStarted': true,
    'isEnded': false,
  };

  final roundMap = <String, dynamic>{
    'isScored': false,
    'initialPhrase': 'testingphrase',
    'subPhrases': {
      'testidlmao1': ['testing', 'test'],
      'testidlmao2': ['testingphras', 'testin', 'tet'],
    },
    'scores': {'testidlmao1': 2, 'testidlmao2': 3},
  };

  final game = Game.fromJson(gameMap);
  print(game.isStarted);
  print(game.isEnded);
  print(game.playerNames);

  final round = Round.fromJson(roundMap);
  print(round.initialPhrase);
  print(round.subPhrases.toString());
  print(round.scores.toString());
  print(round.isScored);
}
