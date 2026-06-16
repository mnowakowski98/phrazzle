import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';

part 'phrazzle_central.g.dart';

final game = Phrazzle();

/// Service for the creation, cordination and status of games
class PhrazzleCentral {
  /// Get information about a given game
  @Route.get('/game/')
  Future<Response> getGameInformation() async {
    throw Exception('Not implemented');
  }

  /// Create a new game
  @Route.post('/game/')
  Future<Response> createGame(Request request) async {
    throw Exception('Not implemented');
  }

  /// Set a starting phrase for a given game
  @Route.put('/game/set/<phrase>')
  Future<Response> setGamePhrase(Request request, String phrase) async {
    throw Exception('Not implemented');
  }

  /// Join a game with a given player name
  @Route.post('/game/join/<player>')
  Future<Response> joinGame(Request request, String player) async {
    throw Exception('Not implemeted');
  }

  /// Start a game
  @Route.put('/game/start/<gameId>')
  Future<Response> startGame(Request request, String gameId) async {
    throw Exception('Not implemented');
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
