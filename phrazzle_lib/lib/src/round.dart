import 'dart:async';
import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'round.g.dart';

@JsonSerializable(explicitToJson: true, createFactory: false)
class Round {
  final String initialPhrase;

  final Map<String, List<String>> _phrases;
  Map<String, List<String>> get phrases => Map.unmodifiable(_phrases);

  final Map<String, bool> _phraseLocks;
  Map<String, bool> get phraseLocks => Map.unmodifiable(_phraseLocks);
  int get lockedPhrases => _phraseLocks.values.fold(
    0,
    (accumulator, value) => value == true ? accumulator + 1 : accumulator
  );

  @JsonKey(includeToJson: false)
  Iterable<String> get lockedPhraseIds => _phraseLocks.keys.where((key) => _phraseLocks[key] == true);

  @JsonKey(includeToJson: false)
  int get unlockedPhrases => _phraseLocks.length - lockedPhrases;

  @JsonKey(includeToJson: false)
  Iterable<String> get unlockedPhraseIds => _phraseLocks.keys.where((key) => _phraseLocks[key] == false);

  final Map<String, int> _scores;
  Map<String, int> get scores => Map.unmodifiable(_scores);

  var _isScored = false;
  bool get isScored => _isScored;

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

  Round._internal(this.initialPhrase, this._phrases, this._scores, this._phraseLocks);

  /// Create sub phrase map from a list of players
  factory Round(String initialPhrase, List<String> playerIds) {
    return Round._internal(
      initialPhrase,
      Map.fromEntries(playerIds.map((id) => MapEntry(id, <String>[]))),
      Map.fromEntries(playerIds.map((id) => MapEntry(id, 0))),
      Map.fromEntries(playerIds.map((id) => MapEntry(id, false)))
    );
  }

  factory Round.fromJson(Map<String, dynamic> json) {
    final Map<String, dynamic> phrasesRaw = json['phrases'];
    final phrases = phrasesRaw.map(
      (key, value) => MapEntry(key, List<String>.from(value)),
    );
    final Map<String, dynamic> scoresRaw = json['scores'];
    final scores = scoresRaw.map(
      (key, value) => MapEntry<String, int>(key, value),
    );
    final Map<String, dynamic> phraseLocksRaw = json['phraseLocks'];
    final phraseLocks = phraseLocksRaw.map((key, value) => MapEntry<String, bool>(key, value));
    final round = Round._internal(json['initialPhrase'], phrases, scores, phraseLocks);
    round._isScored = json['isScored'];
    return round;
  }

  Map<String, dynamic> toJson() {
    final json = _$RoundToJson(this);
    json['typeKey'] = 'round';
    return json;
  }

  /// Add a sub phrase for a player
  void addPlayerSubPhrase(String playerId, String subPhrase) {
    if (_isScored) throw Exception('Round has already been scored');
    if (phraseLocks[playerId] == true) throw Exception('Player has already locked');

    _phrases[playerId]?.add(subPhrase);
    if (_sendUpdates) _updateJsonStringController?.sink.add(jsonEncode(toJson()));
  }

  void lockPhrases(String playerId) {
    if (phraseLocks[playerId] == null) throw Exception('Player does not exist');
    _phraseLocks[playerId] = true;
    if (_sendUpdates) _updateJsonStringController?.sink.add(jsonEncode(toJson()));
  }
}
