import 'package:phrazzle_lib/phrazzle.dart';

abstract class GameStore {
  Iterable<String> get gameIds;

  String createGame(Game game);
  void saveGame(String gameId, Game game);
  Game? getGame(String gameId);
  void removeGame(String gameId);

  String createRound(Round round);
  void saveRound(String roundId, Round round);
  Round? getRound(String roundId);
  Iterable<Round>? getRounds(String gameId);
}