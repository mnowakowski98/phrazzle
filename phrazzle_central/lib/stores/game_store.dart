import 'package:phrazzle_lib/phrazzle.dart';

abstract class GameStore {
  Iterable<String> get gameIds;

  String createGame(Game game);
  Game? getGame(String gameId);
  void removeGame(String gameId);
}