// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Round _$RoundFromJson(Map<String, dynamic> json) => Round.existing(
  json['phrase'] as String,
  (json['phraseGroups'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, PhraseGroup.fromJson(e as Map<String, dynamic>)),
  ),
);

Map<String, dynamic> _$RoundToJson(Round instance) => <String, dynamic>{
  'phrase': instance.phrase,
  'phraseGroups': instance.phraseGroups,
};
