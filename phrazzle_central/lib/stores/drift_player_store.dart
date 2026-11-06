import 'package:phrazzle_central/database.dart' show AppDatabase, PlayerRecordsCompanion;
import 'package:phrazzle_central/stores/player_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class DriftPlayerStore implements PlayerStore {
  final AppDatabase _database;

  DriftPlayerStore(this._database);

  @override
  Future<void> setPlayerRecord(String gameId, String playerId, String userId) async {
    // TODO: implement setPlayerRecord
  }

  @override
  Future<Iterable<PlayerRecord>> getGameRecords(String gameId) async {
    // TODO: implement getGameRecords
    throw UnimplementedError();
  }

  @override
  Future<PlayerRecord?> getPlayerRecord(String playerId) async {
    // TODO: implement getPlayerRecord
    throw UnimplementedError();
  }

  @override
  Future<Iterable<PlayerRecord>> getUserRecords(String userId) async {
    // TODO: implement getUserRecords
    throw UnimplementedError();
  }

  @override
  Future<void> removeGameRecords(String gameId) async {
    // TODO: implement removeGameRecords
    throw UnimplementedError();
  }

  @override
  Future<void> removePlayerRecord(String playerId) {
    // TODO: implement removePlayerRecord
    throw UnimplementedError();
  }
}