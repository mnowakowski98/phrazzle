import 'dart:async';
import 'dart:io';

import 'package:path/path.dart';
import 'package:phrazzle_central/stores/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

class JsonGameStore implements GameStore {
  final Directory _storeDirectory;
  Directory get _gamesDirectory => Directory(normalize(join(_storeDirectory.path, 'games/')));

  JsonGameStore._internal(this._storeDirectory);

  factory JsonGameStore(String storePath) {
    final storeDirectory = Directory(normalize(storePath));
    if (storeDirectory.existsSync() == false) storeDirectory.createSync();

    final gamesDirectory = Directory(normalize(join(storeDirectory.path, './games/')));
    if (gamesDirectory.existsSync() == false) gamesDirectory.createSync();

    return JsonGameStore._internal(Directory(normalize(storePath))); 
  }

  File _getStoreFile(Directory directory, String id) => File(normalize(join(directory.path, '$id.json')));

  @override
  Future<Iterable<String>> get gameIds async => _gamesDirectory.listSync().map((file) => basenameWithoutExtension(file.path));

  final _gamesCache = <String, Game>{};
  final _subscriptions = <String, StreamSubscription<GameInfo>>{};

  Future<void> _uncacheGame(String gameId) async {
    final sub = _subscriptions[gameId];
    if (sub != null) {
      await sub.cancel();
      _subscriptions.remove(gameId);
    }

    final cached = _gamesCache[gameId];
    if (cached != null) _gamesCache.remove(gameId);
  }

  void _cacheGame(String gameId, Game game, File file) {
    final cached = _gamesCache[gameId];
    if (cached != null) return;

    _gamesCache[gameId] = game;
    final sub = game.updateStream.listen((_) async {
      if (_subscriptions[gameId] == null) return;
      if (await file.exists() == false) throw ArgumentError('Tried to write $gameId to invalid file');
      await file.writeAsString(game.info.jsonString);
    });
    _subscriptions[gameId] = sub;

    Timer(const Duration(minutes: 10), () => _uncacheGame(gameId));
  }

  @override
  Future<String> createGame(Game game) async {
    final gameId = Uuid().v4();

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (await file.exists()) throw StateError('Game $gameId already exists');

    await file.create();
    await file.writeAsString(game.info.jsonString);
    _cacheGame(gameId, game, file);

    print('Wrote game file $gameId.json');
    return gameId;
  }

  @override
  Future<Game?> getGame(String gameId) async {
    final cached = _gamesCache[gameId];
    if (cached != null) return cached;

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (await file.exists() == false) return null;

    final game = Game.fromInfo(GameInfo.fromJsonString(await file.readAsString()));
    if (game.info.isEnded == false) _cacheGame(gameId, game, file);

    return game;
  }

  @override
  Future<Map<String, Game>> getGames(Set<String> gameIds) async {
    final games = <String, Game>{};
    for (final gameId in gameIds) {
      var game = _gamesCache[gameId];
      if (game == null) {
        final file = _getStoreFile(_gamesDirectory, gameId);
        game = Game.fromInfo(GameInfo.fromJsonString(await file.readAsString()));
        games[gameId] = game;
        if (game.info.isEnded == false) _cacheGame(gameId, game, file);
      }
    }
    return games;
  }


  @override
  Future<void> removeGame(String gameId) async {
    await _uncacheGame(gameId);

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (await file.exists() == true) await file.delete();
  }
}