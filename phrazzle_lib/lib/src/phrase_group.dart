import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'phrase_group.g.dart';

@JsonSerializable(createFactory: false)
class PhraseGroup {
  final String initialPhrase;

  var _isLocked = false;
  bool get isLocked => _isLocked;
  void lock() => _isLocked = true;

  final List<String> _phrases;
  Iterable<String> get phrases => List.unmodifiable(_phrases);

  void addPhrase(String phrase) {
    if (isLocked) throw StateError('Phrase group is locked');
    _phrases.add(phrase);
  }

  PhraseGroup._internal(this.initialPhrase, this._phrases, this._isLocked);
  factory PhraseGroup(String initialPhrase) => PhraseGroup._internal(initialPhrase, [], false);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(_$PhraseGroupToJson(this));
  factory PhraseGroup.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString);
    final initialPhrase = json['initialPhrase'];
    final phrases = json['phrases'];
    final isLocked = json['isLocked'];
    return PhraseGroup._internal(initialPhrase, phrases, isLocked);
  }
}
