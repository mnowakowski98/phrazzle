// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Game _$GameFromJson(Map<String, dynamic> json) => Game.existing(
  (json['players'] as List<dynamic>).map((e) => e as String).toSet(),
  (json['rounds'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, Round.fromJson(e as Map<String, dynamic>)),
  ),
  json['currentRoundId'] as String?,
  json['isStarted'] as bool,
  json['isEnded'] as bool,
);

Map<String, dynamic> _$GameToJson(Game instance) => <String, dynamic>{
  'isStarted': instance.isStarted,
  'isEnded': instance.isEnded,
  'players': instance.players.toList(),
  'rounds': instance.rounds,
  'currentRoundId': instance.currentRoundId,
};
