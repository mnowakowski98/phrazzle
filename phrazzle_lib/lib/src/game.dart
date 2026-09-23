import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

import 'player.dart';
import 'package:uuid/uuid.dart';

part 'game.g.dart';

/// Class that handles Game lobby information
@JsonSerializable(explicitToJson: true, createFactory: false)
class Game {
  @JsonKey(includeFromJson: false, includeToJson: false)
  static const gameStartedMessage = 'Game already started';

  final _players = <String, Player>{};
  Map<String, Player> get players => Map.unmodifiable(_players);

  @JsonKey(includeToJson: false)
  List<String> get playerIds => List.unmodifiable(players.keys.toList());
  @JsonKey(includeToJson: false)
  List<String> get playerNames =>
      List.unmodifiable(players.values.map((player) => player.name));

  var _isStarted = false;
  bool get isStarted => _isStarted;

  var _isEnded = false;
  bool get isEnded => _isEnded;

  Iterable<String> get winners {
    final max = players.values.fold(0, (final currentMax, final value) {
      if (value.score > currentMax) return value.score;
      return currentMax;
    });

    return players.entries
        .where((player) => player.value.score == max)
        .map((player) => player.key);
  }

  var _sendUpdates = false;
  StreamController<Map<String, dynamic>>? _updateController;

  @JsonKey(includeToJson: false)
  Stream<Map<String, dynamic>> get stateStream {
    _updateController ??= StreamController<Map<String, dynamic>>.broadcast(
      onListen: () => _sendUpdates = true,
      onCancel: () => _sendUpdates = false,
    );
    return _updateController!.stream;
  }

  Game();

  Map<String, dynamic> toJson() {
    final json = _$GameToJson(this);
    json['typeKey'] = 'game';
    return json;
  }

  factory Game.fromJson(Map<String, dynamic> json) {
    final game = Game();
    game._isStarted = json['isStarted'];
    game._isEnded = json['isEnded'];
    final Map<String, dynamic> players = json['players'];
    for (final player in players.entries) {
      game._players[player.key] = Player.fromJson(player.value);
    }
    return game;
  }

  /// Add a player to the game and get id
  String addPlayer(String name) {
    if (isStarted) throw StateError(gameStartedMessage);

    final id = Uuid().v4();
    _players[id] = Player(name);

    if (_sendUpdates) _updateController?.add(toJson());
    return id;
  }

  /// Remove a player by id
  Player? removePlayer(String id) {
    if (isStarted) throw StateError(gameStartedMessage);

    final player = _players.remove(id);
    if (_sendUpdates) _updateController?.add(toJson());
    return player;
  }

  /// Increment scores for players given players
  void incrementScores(Map<String, int> scores) {
    for (final entry in scores.entries) {
      _players[entry.key]!.score += entry.value;
    }
    if (_sendUpdates) _updateController?.add(toJson());
  }

  /// Start the game, prevent player map modification
  bool start() {
    if (isStarted) throw StateError(gameStartedMessage);
    if (_players.isEmpty) return false;

    _isStarted = true;
    if (_sendUpdates) _updateController?.add(toJson());
    return true;
  }

  /// End the game
  void end() {
    if (isStarted == false) throw StateError('Game not started yet');
    _isEnded = true;

    if (_sendUpdates) _updateController?.add(toJson());
    _sendUpdates = false;
    _updateController?.close();
  }
}
