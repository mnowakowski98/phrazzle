import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'game_config.g.dart';

@JsonSerializable()
class GameConfig {
  final bool? autoStart;
  final Iterable<String>? roundPhrases;
  final int? playerSlots;

  GameConfig({this.autoStart, this.roundPhrases, this.playerSlots});

  Map<String, dynamic> toJson() => _$GameConfigToJson(this);
  factory GameConfig.fromJson(Map<String, dynamic> json) => _$GameConfigFromJson(json);

  String get jsonString => jsonEncode(toJson());
  factory GameConfig.fromJsonString(String jsonString) => GameConfig.fromJson(jsonDecode(jsonString));
}