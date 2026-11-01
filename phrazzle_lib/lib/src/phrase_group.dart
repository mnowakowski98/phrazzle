import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'phrase_group.g.dart';

@JsonSerializable()
class PhraseGroupInfo {
  final String initialPhrase;
  final Iterable<String> phrases;
  final bool isLocked;

  PhraseGroupInfo({
    required this.initialPhrase,
    required this.phrases,
    required this.isLocked,
  });

  Map<String, dynamic> toJson() => _$PhraseGroupInfoToJson(this);
  factory PhraseGroupInfo.fromJson(Map<String, dynamic> json) => _$PhraseGroupInfoFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(_$PhraseGroupInfoToJson(this));
  factory PhraseGroupInfo.fromJsonString(String jsonString) => PhraseGroupInfo.fromJson(jsonDecode(jsonString));
}

class PhraseGroup {
  PhraseGroupInfo get info => PhraseGroupInfo(initialPhrase: _initialPhrase, phrases: _phrases, isLocked: _isLocked);

  final String _initialPhrase;
  final List<String> _phrases;

  var _isLocked = false;
  void lock() => _isLocked = true;

  String addPhrase(String phrase) {
    if (_isLocked) throw StateError('Phrase group is locked');
    _phrases.add(phrase);
    return phrase;
  }

  PhraseGroup(String initialPhrase) : _initialPhrase = initialPhrase, _phrases = [];
  factory PhraseGroup.fromInfo(PhraseGroupInfo info) {
    final group = PhraseGroup(info.initialPhrase);
    group._phrases.addAll(info.phrases);
    group._isLocked = info.isLocked;
    return group;
  }
}
