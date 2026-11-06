// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'player_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PlayerRecord _$PlayerRecordFromJson(Map<String, dynamic> json) => PlayerRecord(
  json['gameId'] as String,
  json['playerId'] as String,
  json['userId'] as String,
);

Map<String, dynamic> _$PlayerRecordToJson(PlayerRecord instance) =>
    <String, dynamic>{
      'gameId': instance.gameId,
      'playerId': instance.playerId,
      'userId': instance.userId,
    };
