import 'package:drift/drift.dart';
import 'package:path/path.dart';
import 'package:phrazzle_central/database.dart' show AppDatabase, PlayerRecordsCompanion;
import 'package:phrazzle_central/stores/player_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class DriftPlayerStore implements PlayerStore {
  final AppDatabase _database;

  DriftPlayerStore(this._database);

  @override
  Future<void> setPlayerRecord(PlayerRecord record) async {
    final userSelect = _database.select(_database.users)..where((user) => user.uuid.equals(record.userId));
    final userRowId = (await userSelect.getSingle()).id;

    await _database
        .into(_database.playerRecords)
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
    final recordsSelect = _database.select(_database.playerRecords)
      .join([innerJoin(_database.users, _database.users.id.equalsExp(_database.playerRecords.userId))])
      ..where(_database.playerRecords.gameId.equals(gameId));

    final rows = await recordsSelect.get();
    return rows.map((row) {
      final playerRecord = row.readTable(_database.playerRecords);
      final userRecord = row.readTable(_database.users);
      return PlayerRecord(playerRecord.gameId, playerRecord.playerId, userRecord.uuid);
    });
  }

  @override
  Future<PlayerRecord?> getPlayerRecord(String playerId) async {
    final recordSelect = _database.select(_database.playerRecords)
      .join([innerJoin(_database.users, _database.users.id.equalsExp(_database.playerRecords.userId))])
      ..where(_database.playerRecords.playerId.equals(playerId));

    final row = await recordSelect.getSingleOrNull();
    if (row == null) return null;

    final playerRecord = row.readTable(_database.playerRecords);
    final userRecord = row.readTable(_database.users);
    return PlayerRecord(playerRecord.gameId, playerRecord.playerId, userRecord.uuid);
  }

  @override
  Future<Iterable<PlayerRecord>> getUserRecords(String userId) async {
    final recordsSelect = _database.select(_database.playerRecords)
      .join([innerJoin(_database.users, _database.users.id.equalsExp(_database.playerRecords.userId))])
      ..where(_database.users.uuid.equals(userId));

    final rows = await recordsSelect.get();
    return rows.map((row) {
      final playerRecord = row.readTable(_database.playerRecords);
      final userRecord = row.readTable(_database.users);
      return PlayerRecord(playerRecord.gameId, playerRecord.playerId, userRecord.uuid);
    });
  }

  @override
  Future<void> removeGameRecords(String gameId) async {
    final delete = _database.delete(_database.playerRecords)
      ..where((row) => row.gameId.equals(gameId));
    await delete.go();
  }

  @override
  Future<void> removePlayerRecord(String playerId) async {
    final delete = _database.delete(_database.playerRecords)
      ..where((row) => row.gameId.equals(playerId));
    await delete.go();
  }
}