import 'package:phrazzle_lib/phrazzle.dart';
import 'package:test/test.dart';

void main() {
  const testPlayerName = 'test';

  group('Game not started', () {
    test('Game started returns false', () {
      final game = Phrazzle();
      expect(game.isStarted, false);
    });

    test('Can add a player', () {
      final game = Phrazzle();
      final id = game.addPlayer(testPlayerName);
      expect(true, game.players.containsKey(id));
    });

    test('Can remove a player', () {
      final game = Phrazzle();
      final id = game.addPlayer(testPlayerName);

      final removedPlayer = game.removePlayer(id);
      expect(false, game.players.containsValue(removedPlayer));
    });

    test('Starts if at least one player is added', () {
      final game = Phrazzle();
      game.addPlayer(testPlayerName);
      expect(game.start(), true);
    });

    test('Does not start if no players are added', () {
      final game = Phrazzle();
      expect(game.start(), false);
    });

    test('Throws StateError when ending', () {
      final game = Phrazzle();
      expect(() => game.end(), throwsStateError);
    });
  });

  group('Game started', () {
    test('Game started returns true', () {
      final game = Phrazzle();
      game.addPlayer(testPlayerName);
      game.start();
      expect(game.isStarted, true);
    });

    // test('Returns winner id on end', () {
    //   final game = Phrazzle();
    //   final id1 = game.addPlayer('test1');
    //   final id2 = game.addPlayer('test2');
    //   game.start();

    //   game.players.entries.contains(element)

    //   game.incrementPlayerScore(id1, 5);
    //   game.incrementPlayerScore(id2, 10);

    //   expect(game.end()[0], id2);
    // });

    // test('Returns multiple winner ids if tied', () {
    //   final game = Phrazzle();
    //   final id1 = game.addPlayer();
    //   final id2 = game.addPlayer();
    //   game.start();

    //   game.incrementPlayerScore(id1, 10);
    //   game.incrementPlayerScore(id2, 10);

    //   final winners = game.end();
    //   expect(winners[0], id1);
    //   expect(winners[1], id2);
    // });

    test('Throws StateError when adding players', () {
      final game = Phrazzle();
      game.addPlayer(testPlayerName);
      game.start();
      expect(() => game.addPlayer(testPlayerName), throwsStateError);
    });

    test('Throws StateError when removing players', () {
      final game = Phrazzle();
      final id = game.addPlayer(testPlayerName);
      game.start();
      expect(() => game.removePlayer(id), throwsStateError);
    });

    test('Throws StateError when starting', () {
      final game = Phrazzle();
      game.addPlayer(testPlayerName);
      game.start();
      expect(() => game.start(), throwsStateError);
    });
  });

  group('Scoring', () {
    test('Scores number of phrases if all are valid', () {});

    test('Scores up to invalid phrase if any are invalid', () {});
  });
}
