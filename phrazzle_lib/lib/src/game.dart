import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:phrazzle_lib/phrazzle.dart';

import 'package:uuid/uuid.dart';

part 'game.g.dart';

@JsonSerializable()
class GameInfo {
  final bool isStarted;
  final bool isEnded;
  final Set<String> players;
  final Map<String, RoundInfo> rounds;
  final String? currentRoundId;

  @JsonKey(includeToJson: false)
  RoundInfo? get currentRound => rounds[currentRoundId];

  GameInfo({
    required this.isStarted,
    required this.isEnded,
    required this.players,
    required this.rounds,
    required this.currentRoundId,
  });

  Map<String, dynamic> toJson() => _$GameInfoToJson(this);
  factory GameInfo.fromJson(Map<String, dynamic> json) => _$GameInfoFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(toJson());
  factory GameInfo.fromJsonString(String jsonString) => GameInfo.fromJson(jsonDecode(jsonString));
}

/// Class that handles Game lobby information
class Game {
  GameInfo get info => GameInfo(
    isStarted: _isStarted,
    isEnded: _isEnded,
    players: Set.unmodifiable(_players),
    rounds: Map.unmodifiable({ for (final round in _rounds.entries) round.key : round.value.info }),
    currentRoundId: _currentRoundId,
  );

  var _sendUpdates = false;
  StreamController<GameInfo>? _updateController;

  Stream<GameInfo> get updateStream {
    _updateController ??= StreamController<GameInfo>.broadcast(
      onListen: () => _sendUpdates = true,
      onCancel: () => _sendUpdates = false
    );
    return _updateController!.stream;
  }

  static const gameStartedMessage = 'Game already started';

  var _isStarted = false;

  /// Start the game, prevent player set modification
  bool start() {
    if (_isStarted) throw StateError(gameStartedMessage);
    if (_players.isEmpty) return false;

    _isStarted = true;
    if (_sendUpdates) _updateController?.add(info);
    return true;
  }

  var _isEnded = false;

  /// End the game
  void end() {
    if (_isStarted == false) throw StateError('Game not started yet');
    if (_isEnded == true) throw StateError('Game has already ended');

    _isEnded = true;

    if (_sendUpdates) _updateController?.add(info);
    _sendUpdates = false;
    _updateController?.close();
  }

  final _players = <String>{};

  /// Add a player to the game and get id
  String addPlayer() {
    if (_isStarted) throw StateError(gameStartedMessage);

    final id = Uuid().v4();
    _players.add(id);

    if (_sendUpdates) _updateController?.add(info);
    return id;
  }

  /// Remove a player by id
  void removePlayer(String id) {
    if (_isStarted) throw StateError(gameStartedMessage);

    _players.remove(id);
    if (_sendUpdates) _updateController?.add(info);
  }

  final _rounds = <String, Round>{};

  /// Create a new round
  ({String id, Round round}) createRound(String phrase) {
    final roundId = Uuid().v4();
    final round = Round(phrase, _players);
    _rounds[roundId] = round;

    if (_sendUpdates) _updateController?.add(info);
    return (id: roundId, round: round);
  }

  String? _currentRoundId;
  set currentRoundId(String? id) {
    final round = _rounds[id];
    if (id != null && round == null) throw ArgumentError('Tried to set invalid round $id as current');
    _currentRoundId = id;

    if (_sendUpdates) _updateController?.add(info);
  }

  Round? get _currentRound => _rounds[_currentRoundId];

  String addPhrase(String playerId, String phrase) {
    final round = _currentRound;
    if (round == null) throw StateError('No current round');

    final addedPhrase = round.addPhrase(playerId, phrase);
    if (_sendUpdates) _updateController?.add(info);
    return addedPhrase;
  }

  void lockPlayer(String playerId) {
    final round = _currentRound;
    if (round == null) throw StateError('No current round');

    final group = round.getGroup(playerId);
    if (group == null) throw ArgumentError('Tried to lock invalid player $playerId');
    group.lock();

    if (_sendUpdates) _updateController?.add(info);
  }

  Game();
  factory Game.fromInfo(GameInfo info) {
    final game = Game();
    game._players.addAll(info.players);
    for (final round in info.rounds.entries) {
      game._rounds[round.key] = Round.fromInfo(round.value);
    }
    if (info.isStarted == false && info.isEnded == true) throw ArgumentError('Game can not be ended if it is not started');
    game._isStarted = info.isStarted;
    game._isEnded = info.isEnded;
    game._currentRoundId = info.currentRoundId;
    return game;
  }
}