import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:phrazzle_central/stores/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

class JsonGameStore extends GameStore {
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
  Iterable<String> get gameIds => _gamesDirectory.listSync().map((file) => basenameWithoutExtension(file.path));

  final _gamesCache = <String, Game>{};
  void _cacheGame(String gameId, Game game, File file) {
    _gamesCache[gameId] = game;
    game.jsonStringStream.listen((data) {
      if (file.existsSync() == false) throw ArgumentError('Tried to write $gameId to invalid file');
      file.writeAsStringSync(data);
    });
  }

  @override
  String createGame(Game game) {
    final gameId = Uuid().v4();

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync()) throw StateError('Game $gameId already exists');

    file.createSync();
    file.writeAsStringSync(game.jsonString);
    _cacheGame(gameId, game, file);

    print('Wrote game file $gameId.json');
    return gameId;
  }

  @override
  Game? getGame(String gameId) {
    final cached = _gamesCache[gameId];
    if (cached != null) return cached;

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) return null;

    final fileText = file.readAsStringSync();
    final json = jsonDecode(fileText);

    final game = Game.fromJsonString(json);
    _cacheGame(gameId, game, file);

    print('Cached game $gameId');
    return game;
  }

  @override
  void removeGame(String gameId) {
    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) return;
    file.delete();
    _gamesCache.remove(gameId);
  }

  @override
  User getUser(String gameId, String playerId) {
    // TODO: implement getUser
    throw UnimplementedError();
  }
}