import 'package:json_annotation/json_annotation.dart';

import 'phrazzle_base.dart';

part 'round.g.dart';

@JsonSerializable()
class RoundInfo {
  final String initialPhrase;
  final Map<String, List<String>> subPhrases;
  final Map<String, int> scores;
  final bool isScored;

  RoundInfo({
    required this.initialPhrase,
    required this.subPhrases,
    required this.scores,
    required this.isScored,
  });

  factory RoundInfo.fromJson(Map<String, dynamic> json) =>
      _$RoundInfoFromJson(json);
  Map<String, dynamic> toJson() => _$RoundInfoToJson(this);
}

class Round {
  final String initialPhrase;

  final Map<String, List<String>> _subPhrases;
  Map<String, List<String>> get subPhrases => Map.unmodifiable(_subPhrases);

  final Map<String, int> _scores;
  Map<String, int> get scores => Map.unmodifiable(_scores);

  var _isScored = false;
  bool get isScored => _isScored;

  Round._internal(this.initialPhrase, this._subPhrases, this._scores);

  /// Create sub phrase map from a list of players
  factory Round(String initialPhrase, List<String> playerIds) {
    return Round._internal(
      initialPhrase,
      Map.fromEntries(playerIds.map((id) => MapEntry(id, <String>[]))),
      Map.fromEntries(playerIds.map((id) => MapEntry(id, 0))),
    );
  }

  /// Add a sub phrase for a player
  void addPlayerSubPhrase(String playerId, String subPhrase) {
    if (_isScored) throw Exception('Round has already been scored');
    _subPhrases[playerId]?.add(subPhrase);
  }

  /// Set player scores from their sub phrases
  void scoreRound() {
    if (isScored) throw Exception('Round has already been scored');
    for (final entry in _subPhrases.entries) {
      final score = PhrazzleBase.getNumberOfValidPhrases(
        initialPhrase,
        entry.value,
      );
      _scores[entry.key] = score;
    }
    _isScored = true;
  }

  RoundInfo export() {
    return RoundInfo(
      initialPhrase: initialPhrase,
      subPhrases: subPhrases,
      scores: scores,
      isScored: isScored,
    );
  }
}
