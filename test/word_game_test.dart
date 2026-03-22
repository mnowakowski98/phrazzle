import 'package:word_game/word_game.dart';
import 'package:test/test.dart';

void main() {
  final game = WordGame();

  test('Valid sub phrase', () {
    final rootPhrase = 'dip mcshit';
    final subPhrase = 'dim';
    expect(game.isValidSubPhrase(rootPhrase, subPhrase), true);
  });

  test('Invalid sub phrase: character occurs out of order', () {
    // p is used after c has moved the index
    final rootPhrase = 'dip mcshit';
    final subPhrase = 'chip';
    expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
  });

  test('Invalid sub phrase: Character not in root phrase', () {
    // test does not contain a d
    final rootPhrase = 'test';
    final subPhrase = 'derp';
    expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
  });

  test('Invalid sub phrase: Used whole word from root phrase', () {
    // Dip is a whole word, don't be a lazy fuck
    final rootPhrase = 'dip mcshit';
    final subPhrase = 'dip';
    expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
  });
}
