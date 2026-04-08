import 'package:phrazzle/round.dart';
import 'package:test/test.dart';

void main() {
  test('Select starting phrase', () {
    final testPhrase = 'Test Phrase';
    final round = Round(testPhrase, 2);
    expect(round.phrase, testPhrase);
  });

  test('Get player chains', () {
    final round = Round('Test Phrase', 2);
    round.addPlayerPhrase(0, 'Phrase 0');
    round.addPlayerPhrase(1, 'Phrase 1');
    expect(round.playerPhrases[0][0], 'Phrase 0');
    expect(round.playerPhrases[1][0], 'Phrase 1');
  });
}
