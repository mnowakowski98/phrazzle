import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:phrazzle_central/stores/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

class JsonGameStore extends GameStore {
  final Directory _storeDirectory;
  File get _gameRoundsFile => File(normalize(join(_storeDirectory.path, './gameRounds.json')));
  Directory get _gamesDirectory => Directory(normalize(join(_storeDirectory.path, 'games/')));
  Directory get _roundsDirectory => Directory(normalize(join(_storeDirectory.path, 'rounds/')));

  JsonGameStore._internal(this._storeDirectory);

  factory JsonGameStore(String storePath) {
    final storeDirectory = Directory(normalize(storePath));
    if (storeDirectory.existsSync() == false) storeDirectory.createSync();

    final gameRoundsFile = File(normalize(join(storeDirectory.path, './gameRounds.json')));
    if (gameRoundsFile.existsSync() == false) {
       gameRoundsFile.createSync();
       gameRoundsFile.writeAsStringSync('[]');
    }

    final gamesDirectory = Directory(normalize(join(storeDirectory.path, './games/')));
    if (gamesDirectory.existsSync() == false) gamesDirectory.createSync();
    final roundsDirectory = Directory(normalize(join(storeDirectory.path, './rounds/')));
    if (roundsDirectory.existsSync() == false) roundsDirectory.createSync();

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
    file.writeAsStringSync(jsonEncode(game.toJson()));
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

    final game = Game.fromJson(json);
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

    final gameRounds = jsonDecode(_gameRoundsFile.readAsStringSync()) as List<String>;
    final matchedGameRounds = gameRounds.where((gameRound) => gameRound.split(':')[0] == gameId);
    if (matchedGameRounds.isEmpty) return;

    for (final gameRound in matchedGameRounds) {
      final roundId = gameRound.split(':')[1];
      final file = _getStoreFile(_roundsDirectory, roundId);
      file.deleteSync();
      _roundsCache.remove(roundId);
    }
  }

  final _roundsCache = <String, Round>{};
  void _cacheRound(String roundId, Round round, File file) {
    _roundsCache[roundId] = round;
    round.jsonStringStream.listen((data) {
      if (file.existsSync() == false) throw ArgumentError('Tried to write $roundId to invalid file');
      file.writeAsStringSync(data);
    });
  }

  @override
  String createRound(String gameId, Round round) {
    final roundId = Uuid().v4();

    final file = _getStoreFile(_roundsDirectory, roundId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(round.toJson()));

    final gameRounds = (jsonDecode(_gameRoundsFile.readAsStringSync()) as Iterable).map((item) => item as String).toList();
    gameRounds.add('$gameId:$roundId');
    _gameRoundsFile.writeAsStringSync(jsonEncode(gameRounds));
    _cacheRound(roundId, round, file);

    return roundId;
  }

  @override
  Round? getRound(String roundId) {
    final cached = _roundsCache[roundId];
    if (cached != null) return cached;

    final file = _getStoreFile(_roundsDirectory, roundId);
    if (file.existsSync() == false) return null;

    final fileText = file.readAsStringSync();
    final json = jsonDecode(fileText);

    final round = Round.fromJson(json);
    round.jsonStringStream.listen((data) {
      if (file.existsSync() == false) file.createSync();
      file.writeAsStringSync(jsonEncode(data));
    });

    _cacheRound(roundId, round, file);
    return round;
  }

  @override
  Iterable<Round>? getRounds(String gameId) { 
    final json = jsonDecode(_gameRoundsFile.readAsStringSync()) as Iterable;
    final gameRounds = json.map((item) => item as String);
    final matchedGameRounds = gameRounds.where((gameRound) => gameRound.split(':')[0] == gameId);
    if (matchedGameRounds.isEmpty) return null;

    return matchedGameRounds.map((gameRound) {
      final roundId = gameRound.split(':')[1];
      final round = getRound(roundId);
      if (round == null) throw Exception('Game $gameId matched missing round $roundId');
      return round;
    });
  }
}