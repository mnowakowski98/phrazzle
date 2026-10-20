import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:phrazzle_central/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

class JsonGameStore extends GameStore {
  final Directory _storeDirectory;
  Directory get _gamesDirectory => Directory(normalize(join(_storeDirectory.path, 'games/')));
  Directory get _roundsDirectory => Directory(normalize(join(_storeDirectory.path, 'rounds/')));

  final _gamesCache = <String, Game>{};
  final _roundsCache = <String, Round>{};

  JsonGameStore._internal(this._storeDirectory);

  factory JsonGameStore(String storePath) {
    final storeDirectory = Directory(normalize(storePath));
    if (storeDirectory.existsSync() == false) storeDirectory.createSync();

    final gamesDirectory = Directory(normalize(join(storeDirectory.path, './games/')));
    if (gamesDirectory.existsSync() == false) gamesDirectory.createSync();
    final roundsDirectory = Directory(normalize(join(storeDirectory.path, 'rounds/')));
    if (roundsDirectory.existsSync() == false) roundsDirectory.createSync();

    return JsonGameStore._internal(Directory(normalize(storePath))); 
  }

  File _getStoreFile(Directory directory, String id) => File(normalize(join(directory.path, '$id.json')));

  @override
  // TODO: implement gameIds
  Iterable<String> get gameIds {
    if (_gamesCache.length == _gamesDirectory.listSync().length) return _gamesCache.keys;
    return _gamesDirectory.listSync().map((file) => basenameWithoutExtension(file.path));
  }

  @override
  String createGame(Game game) {
    final gameId = Uuid().v4();

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(game.toJson()));

    _gamesCache[gameId] = game;
    return gameId;
  }

  @override
  void saveGame(String gameId, Game game) {
    _gamesCache[gameId] = game;
    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(game.toJson()));
  }

  @override
  Game? getGame(String gameId) {
    var game = _gamesCache[gameId];
    if (game == null) {
      final file = _getStoreFile(_gamesDirectory, gameId);
      if (file.existsSync() == false) return null;

      final fileText = file.readAsStringSync();
      final json = jsonDecode(fileText);
      game = Game.fromJson(json);
    }
    return game;
  }

  @override
  void removeGame(String gameId) {
    _gamesCache.remove(gameId);

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) return;
    file.delete();
  }

  @override
  String createRound(Round round) {
    final roundId = Uuid().v4();

    final file = _getStoreFile(_roundsDirectory, roundId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(round.toJson()));

    _roundsCache[roundId] = round;
    return roundId;
  }

  @override
  void saveRound(String roundId, Round round) {
    _roundsCache[roundId] = round;
    final file = _getStoreFile(_roundsDirectory, roundId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(round.toJson()));
  }

  @override
  Round? getRound(String roundId) {
    var round = _roundsCache[roundId];
    if (round == null) {
      final file = _getStoreFile(_roundsDirectory, roundId);
      if (file.existsSync() == false) return null;

      final fileText = file.readAsStringSync();
      final json = jsonDecode(fileText);
      round = Round.fromJson(json);
    }
    return round;
  }

  @override
  Iterable<Round>? getRounds(String gameId) {
    // TODO: Return more than just one round per game
    var round = _roundsCache[gameId];
    if (round == null) {
      final file = _getStoreFile(_roundsDirectory, gameId);
      if (file.existsSync() == false) return null;
      
      final fileText = file.readAsStringSync();
      round = Round.fromJson(jsonDecode(fileText));
    }
    return [round];
  }
}