import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final String id;
  final String _name;
  String get name => _name;

  User._internal(this.id, this._name);
  factory User(String id, String name) => User._internal(id, name);
  factory User.newId(User user) => User._internal(Uuid().v4(), user._name);
  factory User.info(String name) => User._internal('', name);

  Map<String, dynamic> get json => _$UserToJson(this);
  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  String get jsonString => jsonEncode(json);
  factory User.fromJsonString(String jsonString) => User.fromJson(jsonDecode(jsonString));
}