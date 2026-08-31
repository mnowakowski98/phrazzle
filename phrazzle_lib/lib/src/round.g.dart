// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'round.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RoundInfo _$RoundInfoFromJson(Map<String, dynamic> json) => RoundInfo(
  initialPhrase: json['initialPhrase'] as String,
  subPhrases: (json['subPhrases'] as Map<String, dynamic>).map(
    (k, e) =>
        MapEntry(k, (e as List<dynamic>).map((e) => e as String).toList()),
  ),
  scores: Map<String, int>.from(json['scores'] as Map),
  isScored: json['isScored'] as bool,
);

Map<String, dynamic> _$RoundInfoToJson(RoundInfo instance) => <String, dynamic>{
  'initialPhrase': instance.initialPhrase,
  'subPhrases': instance.subPhrases,
  'scores': instance.scores,
  'isScored': instance.isScored,
};
