import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:phrazzle_lib/phrazzle.dart';

part 'round.g.dart';

@JsonSerializable(constructor: 'existing')
class Round {
  final String _phrase;
  String get phrase => _phrase;

  final Map<String, PhraseGroup> _phraseGroups;
  Map<String, PhraseGroup> get phraseGroups => Map.unmodifiable(_phraseGroups);

  String addPhrase(String groupId, String phrase) {
    final group = phraseGroups[groupId];
    if (group == null) throw ArgumentError('Tried to add a phrase to invalid group $groupId');
    group.addPhrase(phrase);
    return phrase;
  }

  Map<String, int> get scores {
    final players = _phraseGroups.keys;
    return {
      for (final player in players)
        // TODO: Actually check for validity of the chain
        player: PhraseValidator.getChainValidationInfo(
          _phrase,
          _phraseGroups[player]!.phrases,
        ).length,
    };
  }

  Round._internal(this._phrase, this._phraseGroups);

  factory Round.existing(String phrase, Map<String, PhraseGroup> phraseGroups) => Round._internal(phrase, phraseGroups);
  factory Round(String phrase, Iterable<String> players) => Round._internal(phrase, {
    for (final player in players) player: PhraseGroup(phrase),
  });

  Map<String, dynamic> toJson() => _$RoundToJson(this);
  factory Round.fromJson(Map<String, dynamic> json) => _$RoundFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(_$RoundToJson(this));
  factory Round.fromJsonString(String jsonString) => _$RoundFromJson(jsonDecode(jsonString));
}