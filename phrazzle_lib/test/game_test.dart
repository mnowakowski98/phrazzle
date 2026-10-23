import 'package:phrazzle_lib/phrazzle.dart';
import 'package:test/test.dart';

void main() {
  group('Game not started', () {
    test('Game started returns false', () {
      final game = Phrazzle();
      expect(game.isStarted, false);
    });

    test('Can add a player', () {
      final game = Phrazzle();
      final id = game.addPlayer();
      expect(true, game.players.contains(id));
    });

    test('Can remove a player', () {
      final game = Phrazzle();
      final id = game.addPlayer();

      game.removePlayer(id);
      expect(false, game.players.contains(id));
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

    test('Throws StateError when ending', () {
      final game = Phrazzle();
      expect(() => game.end(), throwsStateError);
    });
  });

  group('Game started', () {
    test('Game started returns true', () {
      final game = Phrazzle();
      game.addPlayer();
      game.start();
      expect(game.isStarted, true);
    });

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
}
