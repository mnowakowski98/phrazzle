import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

part 'player_record.g.dart';

@JsonSerializable()
class PlayerRecord {
  final String gameId;
  final String playerId;
  final String userId;

  PlayerRecord(this.gameId, this.playerId, this.userId);

  Map<String, dynamic> toJson() => _$PlayerRecordToJson(this);
  factory PlayerRecord.fromJson(Map<String, dynamic> json) => _$PlayerRecordFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(toJson());
  factory PlayerRecord.fromJsonString(String jsonString) => PlayerRecord.fromJson(jsonDecode(jsonString));
}