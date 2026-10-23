import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'package:uuid/uuid.dart';

part 'game.g.dart';

/// Class that handles Game lobby information
@JsonSerializable(explicitToJson: true, createFactory: false)
class Game {
  @JsonKey(includeFromJson: false, includeToJson: false)
  static const gameStartedMessage = 'Game already started';

  final _players = <String>{};
  Set<String> get players => Set.unmodifiable(_players);

  var _isStarted = false;
  bool get isStarted => _isStarted;

  var _isEnded = false;
  bool get isEnded => _isEnded;

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

  Game();

  String get jsonString => jsonEncode(_$GameToJson(this));

  factory Game.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    final game = Game();
    game._isStarted = json['isStarted'];
    game._isEnded = json['isEnded'];
    game._players.addAll((json['players'] as Set).cast<String>());
    return game;
  }

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

  /// Start the game, prevent player set modification
  bool start() {
    if (isStarted) throw StateError(gameStartedMessage);
    if (_players.isEmpty) return false;

    _isStarted = true;
    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
    return true;
  }

  /// End the game
  void end() {
    if (isStarted == false) throw StateError('Game not started yet');
    _isEnded = true;

    if (_sendUpdates) _updateJsonStringController?.add(jsonString);
    _sendUpdates = false;
    _updateJsonStringController?.close();
  }
}
