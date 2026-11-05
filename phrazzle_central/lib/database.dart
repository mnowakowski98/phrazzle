import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:uuid/uuid.dart';

part 'database.g.dart';

class Users extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get uuid => text().unique()();
  TextColumn get name => text()();
}

@DriftDatabase(tables: [Users])
class AppDatabase extends _$AppDatabase {
  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() => NativeDatabase.createInBackground(File('./store/database.sqlite'));

  AppDatabase([QueryExecutor? executor]) : super(executor ?? _openConnection());
}