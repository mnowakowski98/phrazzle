import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:phrazzle_lib/phrazzle.dart';

part 'phrase_group.g.dart';

@JsonSerializable(constructor: 'existing')
class PhraseGroup {
  final String _initialPhrase;
  String get initialPhrase => _initialPhrase;

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

  bool get isValidChain => PhraseValidator.getChainValidationInfo(initialPhrase, _phrases).every((info) => info.isValid);

  PhraseGroup._internal(this._initialPhrase, this._phrases, this._isLocked);
  factory PhraseGroup.existing(String initialPhrase, List<String> phrases, bool isLocked) => PhraseGroup._internal(initialPhrase, phrases, isLocked);
  factory PhraseGroup(String initialPhrase) => PhraseGroup._internal(initialPhrase, [], false);

  Map<String, dynamic> toJson() => _$PhraseGroupToJson(this);
  factory PhraseGroup.fromJson(Map<String, dynamic> json) => _$PhraseGroupFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(_$PhraseGroupToJson(this));
  factory PhraseGroup.fromJsonString(String jsonString) => PhraseGroup.fromJson(jsonDecode(jsonString));
}
