class PlayerStore {
  final _players = <String, String>{};

  String setUserId(String playerId, String userId) => _players[playerId] = userId;
  String? getUserId(String playerId) => _players[playerId];
  String? removeUserId(String playerId) => _players.remove(playerId);
}