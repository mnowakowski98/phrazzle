// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'phrazzle_base.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PhraseValidationInfo _$PhraseValidationInfoFromJson(
  Map<String, dynamic> json,
) => PhraseValidationInfo(
  json['isValid'] as bool,
  matchIndices: (json['matchIndices'] as List<dynamic>?)?.map(
    (e) => (e as num).toInt(),
  ),
  wholeWordMatch: json['wholeWordMatch'] as String?,
);

Map<String, dynamic> _$PhraseValidationInfoToJson(
  PhraseValidationInfo instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'matchIndices': instance.matchIndices?.toList(),
  'wholeWordMatch': instance.wholeWordMatch,
};
