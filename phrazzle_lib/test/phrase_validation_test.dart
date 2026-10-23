import 'package:phrazzle_lib/src/phrase_validator.dart';
import 'package:test/test.dart';

void main() {
  // TODO: Fix all tests after validation function return change

  group('Valid sub phrases', () {
    test('General', () {
      // All letters in sub phrase occur in the root phrase
      // Letters occur in order they occur in the root phrase
      // Does not contain a whole word from the root phrase
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dim';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, true);
    });

    test('Partial word from root phrase', () {
      // her is part of herpty but not the whole word
      final rootPhrase = 'herpty derpty';
      final subPhrase = 'her';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, true);
    });

    test('Ignores capitalization', () {
      final rootPhrase = 'qwerty';
      final subPhrase = 'QwEr';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, true);
    });

    test('Ignores spaces', () {
      final rootPhrase = 'chicken nugget';
      final subPhrase = 'chugg';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, true);
    });
  });

  // TODO: Add test to check for the weird space case
  // Example: qwerty uiop : i o
  // 'i' is after a space, using a space in the subphrase after this should not prevent matching in the remaining string

  // TODO: Add tests for extended validation information

  group('Invalid sub phrases', () {
    test('Sub phrase is empty', () {
      expect(PhraseValidator.getPhraseMatchingInformation('test', '').isValid, false);
    });
    
    test('Character occurs out of order', () {
      // p is used after c has truncated the available letters
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'chip';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });

    test('Valid character is repeated incorrectly', () {
      final rootPhrase = 'qwerty';
      final subPhrase = 'qq';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });

    test('Valid character exceeds number of uses', () {
      final rootPhrase = 'testing test';
      final subPhrase = 'ttttt';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });

    test('Character not in root phrase', () {
      // test does not contain a d, r or p
      final rootPhrase = 'test';
      final subPhrase = 'derp';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });

    test('Used whole word from root phrase', () {
      // Dip is a whole word, don't be a lazy fuck
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dip';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });

    // TODO: Add test to ensure capital variations don't affect whole word matches

    test('Used multiple whole words in root phrase in order', () {
      // Same as above
      final rootPhrase = 'testing words of the testing';
      final subPhrase = 'words of the';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });

    test('Sub phrase is longer than the root phrase', () {
      final rootPhrase = 'test';
      final subPhrase = 'testingtest';
      expect(PhraseValidator.getPhraseMatchingInformation(rootPhrase, subPhrase).isValid, false);
    });
  });
}
