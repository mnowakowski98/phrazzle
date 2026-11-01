// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_config.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameConfig _$GameConfigFromJson(Map<String, dynamic> json) => GameConfig(
  autoStart: json['autoStart'] as bool?,
  roundPhrases: (json['roundPhrases'] as List<dynamic>?)?.map(
    (e) => e as String,
  ),
  playerSlots: (json['playerSlots'] as num?)?.toInt(),
);

Map<String, dynamic> _$GameConfigToJson(GameConfig instance) =>
    <String, dynamic>{
      'autoStart': instance.autoStart,
      'roundPhrases': instance.roundPhrases?.toList(),
      'playerSlots': instance.playerSlots,
    };
