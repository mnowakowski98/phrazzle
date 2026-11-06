typedef PlayerRecord = (String gameId, String playerId, String userId);

class PlayerStore {
  final _playerRecords = <(String, String, String)>{};

  void setPlayerRecord(String gameId, String playerId, String userId) async =>
      _playerRecords.add((gameId, playerId, userId));

  Future<Iterable<PlayerRecord>> getGameRecords(String gameId) async => _playerRecords.where((record) => record.$1 == gameId); 

  Future<PlayerRecord?> getPlayerRecord(String playerId) async =>
      _playerRecords.where((record) => record.$2 == playerId).singleOrNull;

  Future<Iterable<PlayerRecord>> getUserRecords(String userId) async =>
      _playerRecords.where((record) => record.$3 == userId);

  Future<void> removeGameRecords(String gameId) async => _playerRecords.removeWhere((record) => record.$1 == gameId);
}