// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameInfo _$GameInfoFromJson(Map<String, dynamic> json) => GameInfo(
  isStarted: json['isStarted'] as bool,
  isEnded: json['isEnded'] as bool,
  players: (json['players'] as List<dynamic>).map((e) => e as String).toSet(),
  rounds: (json['rounds'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, RoundInfo.fromJson(e as Map<String, dynamic>)),
  ),
  currentRoundId: json['currentRoundId'] as String?,
);

Map<String, dynamic> _$GameInfoToJson(GameInfo instance) => <String, dynamic>{
  'isStarted': instance.isStarted,
  'isEnded': instance.isEnded,
  'players': instance.players.toList(),
  'rounds': instance.rounds,
  'currentRoundId': instance.currentRoundId,
};
