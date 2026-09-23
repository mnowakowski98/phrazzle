// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Player _$PlayerFromJson(Map<String, dynamic> json) =>
    Player(json['name'] as String)..score = (json['score'] as num).toInt();

Map<String, dynamic> _$PlayerToJson(Player instance) => <String, dynamic>{
  'name': instance.name,
  'score': instance.score,
};
