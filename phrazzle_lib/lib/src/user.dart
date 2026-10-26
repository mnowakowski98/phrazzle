import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

// This class isn't really a part of the game.
// It's here because I don't have a better way to share types between phrazzle and phrazzle_central.

@JsonSerializable()
class User {
  final String _id;
  String get id => _id;
  final String _name;
  String get name => _name;

  User._internal(this._id, this._name);
  factory User(String id, String name) => User._internal(id, name);
  factory User.blank() => User._internal('', '');
  factory User.newId(User user) => User._internal(Uuid().v4(), user._name);
  factory User.info(String name) => User._internal('', name);

  Map<String, dynamic> toJson() => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(toJson());
  factory User.fromJsonString(String jsonString) => User.fromJson(jsonDecode(jsonString));
}