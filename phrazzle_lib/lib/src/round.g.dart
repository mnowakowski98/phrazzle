// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoundInfo _$RoundInfoFromJson(Map<String, dynamic> json) => RoundInfo(
  phrase: json['phrase'] as String,
  phraseGroups: (json['phraseGroups'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, PhraseGroupInfo.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$RoundInfoToJson(RoundInfo instance) => <String, dynamic>{
  'phrase': instance.phrase,
  'phraseGroups': instance.phraseGroups,
};
