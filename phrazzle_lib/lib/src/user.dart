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

  bool get isInfo => _id == 'info';
  bool get isAnonymous => _id == 'anonymous';
  bool get isUser => _id.isNotEmpty && isInfo == false && isAnonymous == false;

  User(String id, String name) : _id = id, _name = name;
  User.blank() : _id = '', _name = '';
  User.anonymous() : _id = 'anonymous', _name = '';
  User.namedAnonymous(String name) : _id = 'anonymous', _name = name;
  User.info(String name) : _id = 'info', _name = name;
  User.pending(String id) : _id = id, _name = '';
  User.newId(User user) : _id = Uuid().v4(), _name = user._name;

  Map<String, dynamic> toJson() => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @JsonKey(includeToJson: false)
  String get jsonString => jsonEncode(toJson());
  factory User.fromJsonString(String jsonString) => User.fromJson(jsonDecode(jsonString));
}