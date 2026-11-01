import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:phrazzle_lib/phrazzle.dart';

part 'round.g.dart';

@JsonSerializable()
class RoundInfo {
  final String phrase;
  final Map<String, PhraseGroupInfo> phraseGroups;

  Map<String, int> get scores {
    final players = phraseGroups.keys;
    return {
      for (final player in players)
        // TODO: Actually check for validity of the chain
        player: PhraseValidator.getChainValidationInfo(
          phrase,
          phraseGroups[player]!.phrases,
        ).length,
    };
  }

  RoundInfo({required this.phrase, required this.phraseGroups});

  Map<String, dynamic> toJson() => _$RoundInfoToJson(this);
  factory RoundInfo.fromJson(Map<String, dynamic> json) => _$RoundInfoFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(_$RoundInfoToJson(this));
  factory RoundInfo.fromJsonString(String jsonString) => _$RoundInfoFromJson(jsonDecode(jsonString));
}

class Round {
  RoundInfo get info => RoundInfo(
    phrase: _phrase,
    phraseGroups: Map.unmodifiable({
      for (final group in _phraseGroups.entries) group.key: group.value.info,
    }),
  );

  final String _phrase;
  final Map<String, PhraseGroup> _phraseGroups;
  PhraseGroup? getGroup(String groupId) => _phraseGroups[groupId];

  String addPhrase(String groupId, String phrase) {
    final group = _phraseGroups[groupId];
    if (group == null) throw ArgumentError('Tried to add a phrase to invalid group $groupId');
    group.addPhrase(phrase);
    return phrase;
  }

  Round(String phrase, Iterable<String> groups)
    : _phrase = phrase,
      _phraseGroups = {for (final group in groups) group: PhraseGroup(phrase)};

  factory Round.fromInfo(RoundInfo info) {
    final round = Round(info.phrase, info.phraseGroups.keys);
    for (final groupInfo in info.phraseGroups.entries) {
      round._phraseGroups[groupInfo.key] = PhraseGroup.fromInfo(groupInfo.value);
    }
    return round;
  }
}