// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrase_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseGroupInfo _$PhraseGroupInfoFromJson(Map<String, dynamic> json) =>
    PhraseGroupInfo(
      initialPhrase: json['initialPhrase'] as String,
      phrases: (json['phrases'] as List<dynamic>).map((e) => e as String),
      isLocked: json['isLocked'] as bool,
    );

Map<String, dynamic> _$PhraseGroupInfoToJson(PhraseGroupInfo instance) =>
    <String, dynamic>{
      'initialPhrase': instance.initialPhrase,
      'phrases': instance.phrases.toList(),
      'isLocked': instance.isLocked,
    };
