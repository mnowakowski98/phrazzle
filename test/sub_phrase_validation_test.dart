import 'package:phrazzle/word_game.dart';
import 'package:test/test.dart';

void main() {
  final game = WordGame();

  group('Valid sub phrases', () {
    test('General', () {
      // All letters in sub phrase occur in the root phrase
      // Letters occur in order they occur in the root phrase
      // Does not contain a whole word from the root phrase
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dim';
      expect(game.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Partial word from root phrase', () {
      // her is part of herpty but not the whole word
      final rootPhrase = 'herpty derpty';
      final subPhrase = 'her';
      expect(game.isValidSubPhrase(rootPhrase, subPhrase), true);
    });
  });

  group('Invalid sub phrases', () {
    test('Character occurs out of order', () {
      // p is used after c has truncated the available letters
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'chip';
      expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Character not in root phrase', () {
      // test does not contain a d, r or p
      final rootPhrase = 'test';
      final subPhrase = 'derp';
      expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Used whole word from root phrase', () {
      // Dip is a whole word, don't be a lazy fuck
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dip';
      expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Used multiple whole words in root phrase in order', () {
      // Same as above
      final rootPhrase = 'testing words of the testing';
      final subPhrase = 'words of the';
      expect(game.isValidSubPhrase(rootPhrase, subPhrase), false);
    });
  });
}
