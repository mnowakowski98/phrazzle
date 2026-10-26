import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:phrazzle_lib/src/round.dart';

import 'package:uuid/uuid.dart';

part 'game.g.dart';

/// Class that handles Game lobby information
@JsonSerializable(constructor: 'existing')
class Game {
  var _sendUpdates = false;
  StreamController<String>? _updateJsonStringController;

  @JsonKey(includeToJson: false)
  Stream<String> get jsonStringStream {
    _updateJsonStringController ??= StreamController<String>.broadcast(
      onListen: () => _sendUpdates = true,
      onCancel: () => _sendUpdates = false
    );
    return _updateJsonStringController!.stream;
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  static const gameStartedMessage = 'Game already started';

  var _isStarted = false;
  bool get isStarted => _isStarted;

  /// Start the game, prevent player set modification
  bool start() {
    if (isStarted) throw StateError(gameStartedMessage);
    if (_players.isEmpty) return false;

    _isStarted = true;
    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
    return true;
  }

  var _isEnded = false;
  bool get isEnded => _isEnded;

  /// End the game
  void end() {
    if (isStarted == false) throw StateError('Game not started yet');
    if (isEnded == true) throw StateError('Game has already ended');

    _isEnded = true;

    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
    _sendUpdates = false;
    _updateJsonStringController?.close();
  }

  final _players = <String>{};
  Set<String> get players => Set.unmodifiable(_players);

  /// Add a player to the game and get id
  String addPlayer() {
    if (isStarted) throw StateError(gameStartedMessage);

    final id = Uuid().v4();
    _players.add(id);

    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
    return id;
  }

  /// Remove a player by id
  void removePlayer(String id) {
    if (isStarted) throw StateError(gameStartedMessage);

    _players.remove(id);
    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
  }

  final _rounds = <String, Round>{};
  Map<String, Round> get rounds => Map.unmodifiable(_rounds);

  /// Create a new round
  ({String id, Round round}) createRound(String phrase) {
    final roundId = Uuid().v4();
    final round = Round(phrase, players);
    _rounds[roundId] = round;

    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
    return (id: roundId, round: round);
  }

  String? _currentRoundId;
  String? get currentRoundId => _currentRoundId;
  set currentRoundId(String? id) {
    final round = _rounds[id];
    if (id != null && round == null) throw ArgumentError('Tried to set invalid round $id as current');
    _currentRoundId = id;

    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
  }

  @JsonKey(includeToJson: false)
  Round? get currentRound => _rounds[_currentRoundId];

  /// Add a phrase to the current round
  String addPhrase(String playerId, String phrase) {
    if (isStarted == false) throw StateError('Game not started yet');
    if (isEnded == true) throw StateError('Game has ended');

    final round = currentRound;
    if (round == null) throw StateError('Game has no current round');
    return round.addPhrase(playerId, phrase);
  }

  Game();
  factory Game.existing(Set<String> players, Map<String, Round> rounds, bool isStarted, bool isEnded) {
    final game = Game();
    game._players.addAll(players);
    game._rounds.addAll(rounds);
    if (isStarted == false && isEnded == true) throw ArgumentError('Game can not be ended if it is not started');
    game._isStarted = isStarted;
    game._isEnded = isEnded;
    return game;
  }

  Map<String, dynamic> toJson() => _$GameToJson(this);
  factory Game.fromJson(Map<String, dynamic> json) => _$GameFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(toJson());
  factory Game.fromJsonString(String jsonString) => Game.fromJson(jsonDecode(jsonString));
}
