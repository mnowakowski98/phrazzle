import 'package:phrazzle_lib/phrazzle.dart';
import 'package:test/test.dart';

void main() {
  group('Game not started', () {
    test('Can add a player with 0 score', () {
      final game = Phrazzle();
      final id = game.addPlayer();
      expect(game.getPlayerScore(id), 0);
    });

    test('Can remove a player', () {
      final game = Phrazzle();
      final id = game.addPlayer();
      assert(game.getPlayerScore(id) != null);

      final lastScore = game.removePlayer(id);
      expect(lastScore, greaterThanOrEqualTo(0));
      expect(game.getPlayerScore(id), null);
    });

    test('Starts if at least one player is added', () {
      final game = Phrazzle();
      game.addPlayer();
      expect(game.start(), true);
    });

    test('Does not start if no players are added', () {
      final game = Phrazzle();
      expect(game.start(), false);
    });

    test('Throws StateError when incrementing player scores', () {
      final game = Phrazzle();
      final id = game.addPlayer();
      expect(() => game.incrementPlayerScore(id, 5), throwsStateError);
    });

    test('Throws StateError when ending', () {
      final game = Phrazzle();
      expect(() => game.end(), throwsStateError);
    });
  });

  group('Game started', () {
    test('Can increment a player score', () {
      final game = Phrazzle();
      final id = game.addPlayer();
      game.start();

      final amount = 5;
      expect(game.incrementPlayerScore(id, amount), amount);
      expect(game.getPlayerScore(id), amount);
    });

    test('Returns winner id on end', () {
      final game = Phrazzle();
      final id1 = game.addPlayer();
      final id2 = game.addPlayer();
      game.start();

      game.incrementPlayerScore(id1, 5);
      game.incrementPlayerScore(id2, 10);

      expect(game.end()[0], id2);
    });

    test('Returns multiple winner ids if tied', () {
      final game = Phrazzle();
      final id1 = game.addPlayer();
      final id2 = game.addPlayer();
      game.start();

      game.incrementPlayerScore(id1, 10);
      game.incrementPlayerScore(id2, 10);

      final winners = game.end();
      expect(winners[0], id1);
      expect(winners[1], id2);
    });

    test(
      'Throws RangeError if trying to increment a player score that does not exist',
      () {
        final game = Phrazzle();
        game.addPlayer();
        game.start();
        expect(() => game.incrementPlayerScore('derp', 5), throwsRangeError);
      },
    );

    test('Throws StateError when adding players', () {
      final game = Phrazzle();
      game.addPlayer();
      game.start();
      expect(() => game.addPlayer(), throwsStateError);
    });

    test('Throws StateError when removing players', () {
      final game = Phrazzle();
      final id = game.addPlayer();
      game.start();
      expect(() => game.removePlayer(id), throwsStateError);
    });

    test('Throws StateError when starting', () {
      final game = Phrazzle();
      game.addPlayer();
      game.start();
      expect(() => game.start(), throwsStateError);
    });
  });

  group('Scoring', () {
    test('Scores number of phrases if all are valid', () {});

    test('Scores up to invalid phrase if any are invalid', () {});
  });

  group('Valid sub phrases', () {
    test('General', () {
      // All letters in sub phrase occur in the root phrase
      // Letters occur in order they occur in the root phrase
      // Does not contain a whole word from the root phrase
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dim';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Partial word from root phrase', () {
      // her is part of herpty but not the whole word
      final rootPhrase = 'herpty derpty';
      final subPhrase = 'her';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Ignores capitalization', () {
      final rootPhrase = 'qwerty';
      final subPhrase = 'QwEr';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), true);
    });

    test('Ignores spaces', () {
      final rootPhrase = 'chicken nugget';
      final subPhrase = 'chugg';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), true);
    });
  });

  group('Invalid sub phrases', () {
    test('Character occurs out of order', () {
      // p is used after c has truncated the available letters
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'chip';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Character not in root phrase', () {
      // test does not contain a d, r or p
      final rootPhrase = 'test';
      final subPhrase = 'derp';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Used whole word from root phrase', () {
      // Dip is a whole word, don't be a lazy fuck
      final rootPhrase = 'dip mcshit';
      final subPhrase = 'dip';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), false);
    });

    test('Used multiple whole words in root phrase in order', () {
      // Same as above
      final rootPhrase = 'testing words of the testing';
      final subPhrase = 'words of the';
      expect(Phrazzle.isValidSubPhrase(rootPhrase, subPhrase), false);
    });
  });
}
