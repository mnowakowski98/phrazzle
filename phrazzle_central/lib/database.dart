import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
}

class Games extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
}

class Players extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
}

class PlayerRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get gameId => integer().references(Games, #id)();
  IntColumn get playerId => integer().references(Players, #id)();
  IntColumn get userId => integer().references(Users, #id)();
}

@DriftDatabase(tables: [Users, Games, Players, PlayerRecords])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => NativeDatabase.createInBackground(File('./store/database.sqlite'));

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
}