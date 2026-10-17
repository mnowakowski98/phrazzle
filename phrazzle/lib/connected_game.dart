import 'package:phrazzle_lib/phrazzle.dart';

class ConnectedGame {
  final String gameId;
  final String playerId;

  final Game game;
  final Round? round;

  ConnectedGame(this.gameId, this.playerId, this.game, [this.round]);
}