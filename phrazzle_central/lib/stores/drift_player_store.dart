import 'package:drift/drift.dart';
import 'package:phrazzle_central/database.dart' show AppDatabase, PlayerRecordsCompanion;
import 'package:phrazzle_central/stores/player_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class DriftPlayerStore implements PlayerStore {
  final AppDatabase Function() _databaseFunction;

  DriftPlayerStore(this._databaseFunction);

  @override
  Future<void> setPlayerRecord(PlayerRecord record) async {
    final database = _databaseFunction();
    final userSelect = database.select(database.users)..where((user) => user.uuid.equals(record.userId));
    final userRowId = (await userSelect.getSingle()).id;

    await database
        .into(database.playerRecords)
        .insert(
          PlayerRecordsCompanion.insert(
            gameId: record.gameId,
            playerId: record.playerId,
            userId: userRowId,
          ),
        );
  }

  @override
  Future<Iterable<PlayerRecord>> getGameRecords(String gameId) async {
    final database = _databaseFunction();
    final recordsSelect = database.select(database.playerRecords)
      .join([innerJoin(database.users, database.users.id.equalsExp(database.playerRecords.userId))])
      ..where(database.playerRecords.gameId.equals(gameId));

    final rows = await recordsSelect.get();
    return rows.map((row) {
      final playerRecord = row.readTable(database.playerRecords);
      final userRecord = row.readTable(database.users);
      return PlayerRecord(playerRecord.gameId, playerRecord.playerId, userRecord.uuid);
    });
  }

  @override
  Future<PlayerRecord?> getPlayerRecord(String playerId) async {
    final database = _databaseFunction();
    final recordSelect = database.select(database.playerRecords)
      .join([innerJoin(database.users, database.users.id.equalsExp(database.playerRecords.userId))])
      ..where(database.playerRecords.playerId.equals(playerId));

    final row = await recordSelect.getSingleOrNull();
    if (row == null) return null;

    final playerRecord = row.readTable(database.playerRecords);
    final userRecord = row.readTable(database.users);
    return PlayerRecord(playerRecord.gameId, playerRecord.playerId, userRecord.uuid);
  }

  @override
  Future<Iterable<PlayerRecord>> getUserRecords(String userId) async {
    final database = _databaseFunction();
    final recordsSelect = database.select(database.playerRecords)
      .join([innerJoin(database.users, database.users.id.equalsExp(database.playerRecords.userId))])
      ..where(database.users.uuid.equals(userId));

    final rows = await recordsSelect.get();
    return rows.map((row) {
      final playerRecord = row.readTable(database.playerRecords);
      final userRecord = row.readTable(database.users);
      return PlayerRecord(playerRecord.gameId, playerRecord.playerId, userRecord.uuid);
    });
  }

  @override
  Future<void> removeGameRecords(String gameId) async {
    final database = _databaseFunction();
    final delete = database.delete(database.playerRecords)
      ..where((row) => row.gameId.equals(gameId));
    await delete.go();
  }

  @override
  Future<void> removePlayerRecord(String playerId) async {
    final database = _databaseFunction();
    final delete = database.delete(database.playerRecords)
      ..where((row) => row.gameId.equals(playerId));
    await delete.go();
  }
}