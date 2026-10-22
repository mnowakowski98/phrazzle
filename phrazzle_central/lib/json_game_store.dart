import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart';
import 'package:phrazzle_central/game_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:uuid/uuid.dart';

class JsonGameStore extends GameStore {
  final Directory _storeDirectory;
  File get _gameRoundsFile => File(normalize(join(_storeDirectory.path, './gameRounds.json')));
  Directory get _gamesDirectory => Directory(normalize(join(_storeDirectory.path, 'games/')));
  Directory get _roundsDirectory => Directory(normalize(join(_storeDirectory.path, 'rounds/')));

  // final _gamesCache = <String, Game>{};
  // final _roundsCache = <String, Round>{};

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
  // TODO: implement gameIds
  Iterable<String> get gameIds {
    return _gamesDirectory.listSync().map((file) => basenameWithoutExtension(file.path));
  }

  @override
  String createGame(Game game) {
    final gameId = Uuid().v4();

    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(game.toJson()));

    return gameId;
  }

  @override
  Game? getGame(String gameId) {
    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) return null;

    final fileText = file.readAsStringSync();
    final json = jsonDecode(fileText);

    final game = Game.fromJson(json);
    game.stateStream.listen((data) {
      if (file.existsSync() == false) file.createSync();
      file.writeAsStringSync(jsonEncode(data));
    });

    return game;
  }

  @override
  void removeGame(String gameId) {
    final file = _getStoreFile(_gamesDirectory, gameId);
    if (file.existsSync() == false) return;
    file.delete();
  }

  @override
  String createRound(String gameId, Round round) {
    final roundId = Uuid().v4();

    final file = _getStoreFile(_roundsDirectory, roundId);
    if (file.existsSync() == false) file.createSync();
    file.writeAsStringSync(jsonEncode(round.toJson()));

    final gameRoundsFileText = _gameRoundsFile.readAsStringSync();
    final gameRounds = jsonDecode(gameRoundsFileText) as List<dynamic>;
    gameRounds.add({gameId: roundId});

    _gameRoundsFile.writeAsStringSync(jsonEncode(gameRounds));
    return roundId;
  }

  @override
  Round? getRound(String roundId) {
    final file = _getStoreFile(_roundsDirectory, roundId);
    if (file.existsSync() == false) return null;

    final fileText = file.readAsStringSync();
    final json = jsonDecode(fileText);

    final round = Round.fromJson(json);
    round.getUpdateStream().listen((data) {
      if (file.existsSync() == false) file.createSync();
      file.writeAsStringSync(jsonEncode(data));
    });

    return round;
  }

  @override
  Iterable<Round>? getRounds(String gameId) {    
    return [];
  }
}