import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:phrazzle_central/database.steps.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
}

class PlayerRecords extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get gameId => text()();
  TextColumn get playerId => text().unique()();
  IntColumn get userId => integer().references(Users, #id)();
}

@DriftDatabase(tables: [Users, PlayerRecords])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(onUpgrade: stepByStep(from1To2: ((m, schema) async {
    await m.createAll();
  })));

  // Not sure if this needs to be here for the migration tool,
  // check next time it needs to be used
  static QueryExecutor _openConnection() => NativeDatabase.createInBackground(File('./store/database.sqlite'));

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
}