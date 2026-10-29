// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseGroup _$PhraseGroupFromJson(Map<String, dynamic> json) =>
    PhraseGroup.existing(
      json['initialPhrase'] as String,
      (json['phrases'] as List<dynamic>).map((e) => e as String).toList(),
      json['isLocked'] as bool,
    );

Map<String, dynamic> _$PhraseGroupToJson(PhraseGroup instance) =>
    <String, dynamic>{
      'initialPhrase': instance.initialPhrase,
      'isLocked': instance.isLocked,
      'phrases': instance.phrases.toList(),
    };
