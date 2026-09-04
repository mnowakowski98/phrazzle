import 'dart:async';

import 'package:json_annotation/json_annotation.dart';

import 'phrazzle_base.dart';

part 'round.g.dart';

@JsonSerializable(explicitToJson: true, createFactory: false)
class Round {
  final String initialPhrase;

  final Map<String, List<String>> _subPhrases;
  Map<String, List<String>> get subPhrases => Map.unmodifiable(_subPhrases);

  final Map<String, int> _scores;
  Map<String, int> get scores => Map.unmodifiable(_scores);

  var _isScored = false;
  bool get isScored => _isScored;

  var _sendUpdates = false;
  StreamController<Map<String, dynamic>>? _updateController;

  Stream<Map<String, dynamic>> getUpdateStream() {
    _updateController ??= StreamController<Map<String, dynamic>>.broadcast(
      onListen: () => _sendUpdates = true,
      onCancel: () => _sendUpdates = false,
    );

    return _updateController!.stream;
  }

  Round._internal(this.initialPhrase, this._subPhrases, this._scores);

  /// Create sub phrase map from a list of players
  factory Round(String initialPhrase, List<String> playerIds) {
    return Round._internal(
      initialPhrase,
      Map.fromEntries(playerIds.map((id) => MapEntry(id, <String>[]))),
      Map.fromEntries(playerIds.map((id) => MapEntry(id, 0))),
    );
  }

  Map<String, dynamic> toJson() {
    final json = _$RoundToJson(this);
    json['typeKey'] = 'round';
    return json;
  }

  /// Add a sub phrase for a player
  void addPlayerSubPhrase(String playerId, String subPhrase) {
    if (_isScored) throw Exception('Round has already been scored');
    _subPhrases[playerId]?.add(subPhrase);
    if (_sendUpdates) _updateController?.sink.add(toJson());
  }

  /// Set player scores from their sub phrases
  Map<String, int> scoreRound() {
    if (isScored) throw Exception('Round has already been scored');
    for (final entry in _subPhrases.entries) {
      final score = PhrazzleBase.getNumberOfValidPhrases(
        initialPhrase,
        entry.value,
      );
      _scores[entry.key] = score;
    }
    _isScored = true;
    if (_sendUpdates) _updateController?.sink.add(toJson());
    _sendUpdates = false;
    _updateController?.close();
    return scores;
  }
}
