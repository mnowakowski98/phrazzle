import 'package:phrazzle_lib/phrazzle.dart';

class PlayerStore {
  final _playerRecords = <PlayerRecord>{};

  Future<void> setPlayerRecord(PlayerRecord record) async =>
      _playerRecords.add(PlayerRecord(record.gameId, record.playerId, record.userId));

  Future<Iterable<PlayerRecord>> getGameRecords(String gameId) async => _playerRecords.where((record) => record.gameId == gameId); 

  Future<PlayerRecord?> getPlayerRecord(String playerId) async =>
      _playerRecords.where((record) => record.playerId == playerId).singleOrNull;

  Future<Iterable<PlayerRecord>> getUserRecords(String userId) async =>
      _playerRecords.where((record) => record.userId == userId);

  Future<void> removeGameRecords(String gameId) async => _playerRecords.removeWhere((record) => record.gameId == gameId);

  Future<void> removePlayerRecord(String playerId) async => _playerRecords.removeWhere((record) => record.playerId == playerId);
}