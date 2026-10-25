import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'phrase_group.g.dart';

@JsonSerializable()
class PhraseGroup {
  final String initialPhrase;

  var _isLocked = false;
  bool get isLocked => _isLocked;
  void lock() => _isLocked = true;

  final List<String> _phrases;
  Iterable<String> get phrases => List.unmodifiable(_phrases);

  String addPhrase(String phrase) {
    if (isLocked) throw StateError('Phrase group is locked');
    _phrases.add(phrase);
    return phrase;
  }

  PhraseGroup._internal(this.initialPhrase, this._phrases, this._isLocked);
  factory PhraseGroup(String initialPhrase) => PhraseGroup._internal(initialPhrase, [], false);

  Map<String, dynamic> toJson() => _$PhraseGroupToJson(this);
  factory PhraseGroup.fromJson(Map<String, dynamic> json) => _$PhraseGroupFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(_$PhraseGroupToJson(this));
  factory PhraseGroup.fromJsonString(String jsonString) => PhraseGroup.fromJson(jsonDecode(jsonString));
}
