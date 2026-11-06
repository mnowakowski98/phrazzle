typedef PlayerRecord = (String gameId, String playerId, String userId);

class PlayerStore {
  final _playerRecords = <(String, String, String)>{};

  void setPlayerRecord(String gameId, String playerId, String userId) =>
      _playerRecords.add((gameId, playerId, userId));

  Iterable<PlayerRecord> getGameRecords(String gameId) => _playerRecords.where((record) => record.$1 == gameId); 

  PlayerRecord? getPlayerRecords(String playerId) =>
      _playerRecords.where((record) => record.$2 == playerId).singleOrNull;

  Iterable<PlayerRecord> getUserRecords(String userId) =>
      _playerRecords.where((record) => record.$3 == userId);

  void removeGameRecords(String gameId) => _playerRecords.removeWhere((record) => record.$1 == gameId);
}