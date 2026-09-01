// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameInfo _$GameInfoFromJson(Map<String, dynamic> json) => GameInfo(
  playerNames: Map<String, String>.from(json['playerNames'] as Map),
  playerScores: Map<String, int>.from(json['playerScores'] as Map),
  isStarted: json['isStarted'] as bool,
  isEnded: json['isEnded'] as bool,
);

Map<String, dynamic> _$GameInfoToJson(GameInfo instance) => <String, dynamic>{
  'playerNames': instance.playerNames,
  'playerScores': instance.playerScores,
  'isStarted': instance.isStarted,
  'isEnded': instance.isEnded,
};
