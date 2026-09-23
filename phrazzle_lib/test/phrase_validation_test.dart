import 'package:phrazzle_lib/src/phrazzle_base.dart';
import 'package:test/test.dart';

void main() {
  group('Valid sub phrases', () {
    test('General', () {
      // All letters in sub phrase occur in the root phrase
      // Letters occur in order they occur in the root phrase
      // Does not contain a whole word from the root phrase
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dim';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Partial word from root phrase', () {
      // her is part of herpty but not the whole word
      final rootPhrase = 'herpty derpty';
      final subPhrase = 'her';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Ignores capitalization', () {
      final rootPhrase = 'qwerty';
      final subPhrase = 'QwEr';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Ignores spaces', () {
      final rootPhrase = 'chicken nugget';
      final subPhrase = 'chugg';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), true);
    });
  });

  group('Invalid sub phrases', () {
    test('Character occurs out of order', () {
      // p is used after c has truncated the available letters
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'chip';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Character not in root phrase', () {
      // test does not contain a d, r or p
      final rootPhrase = 'test';
      final subPhrase = 'derp';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Used whole word from root phrase', () {
      // Dip is a whole word, don't be a lazy fuck
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dip';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Used multiple whole words in root phrase in order', () {
      // Same as above
      final rootPhrase = 'testing words of the testing';
      final subPhrase = 'words of the';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Sub phrase is longer than the root phrase', () {
      final rootPhrase = 'test';
      final subPhrase = 'testingtest';
      expect(PhrazzleBase.isValidSubPhrase(rootPhrase, subPhrase), false);
    });
  });
}
