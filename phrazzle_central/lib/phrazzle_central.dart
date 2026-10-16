import 'dart:async';
import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:uuid/uuid.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

part 'phrazzle_central.g.dart';

class GameContainer {
  final Game game;
  Round? round;
  final channels = <String, WebSocketChannel>{};

  GameContainer(this.game);
}

// TODO: Abstract away the storage of games
// The game(s) state needs to live past the lifetime of this service
// Implementation can vary based on environment, this class doesn't need to know
Map<String, GameContainer> games = {};

/// Service for the creation, cordination and status of games
class PhrazzleCentral {
  /// Create a new game
  @Route.post('/game')
  Response createGame(Request _) {
    final gameId = Uuid().v4();
    games[gameId] = GameContainer(Game());

    print('Created game $gameId');
    return Response.ok(gameId);
  }

  /// Create a new player in an existing game
  @Route.post('/game/<gameId>/<playerName>')
  Response addPlayer(Request _, String gameId, String playerName) {
    final game = games[gameId]?.game;
    if (game == null) {
      return Response.notFound(gameId);
    }

    final playerId = game.addPlayer(Uri.decodeComponent(playerName));
    print('Created player $playerName ($playerId) in $gameId');
    return Response.ok(playerId);
  }

  /// Join the game as an existing player
  @Route.get('/game/<gameId>/<playerId>')
  FutureOr<Response> joinGame(Request req, String gameId, String playerId) {
    final gameContainer = games[gameId];
    if (gameContainer == null) {
      return Response.notFound(gameId);
    }

    final player = gameContainer.game.players[playerId];
    if (player == null) return Response.notFound(playerId);
    if (gameContainer.channels[playerId] != null) {
      return Response.badRequest(body: jsonEncode({'playerId': playerId, 'message': 'Player already connected'}));
    }

    return webSocketHandler((channel, _) {
      gameContainer.channels[playerId] = channel;

      // Unlink active channel from player (does not delete player)
      channel.sink.done.whenComplete(() {
        gameContainer.channels.remove(playerId);
        print('${player.name} left game $gameId');
      });

      // Send current game state and sync with updates
      channel.sink.add(jsonEncode(gameContainer.game.toJson()));
      gameContainer.game.stateStream.listen(
        (data) => channel.sink.add(jsonEncode(data)),
      );

      // Send/sync round if exists
      if (gameContainer.round != null) {
        channel.sink.add(jsonEncode(gameContainer.round?.toJson()));
        gameContainer.round?.getUpdateStream().listen(
          (data) => channel.sink.add(jsonEncode(data)),
        );
      }

      print('${player.name} joined game $gameId');
    })(req);
  }

  /// Remove an existing player by id
  @Route.delete('/game/<gameId>/<playerId>')
  Response removePlayer(Request _, String gameId, String playerId) {
    final game = games[gameId]?.game;
    if (game == null) return Response.notFound(gameId);

    final player = game.removePlayer(playerId);
    if (player == null) return Response.notFound(playerId);

    print('Removed ${player.name} from $gameId');
    return Response.ok(playerId);
  }

  /// Start the game
  @Route.put('/game/<gameId>/<phrase>')
  Response startGame(Request _, String gameId, String phrase) {
    final gameContainer = games[gameId];
    if (gameContainer == null) return Response.notFound(gameId);

    final started = gameContainer.game.start();
    if (started == false) {
      return Response.badRequest(body: jsonEncode({'gameId': gameId, 'message': 'Game already started'}));
    }

    gameContainer.round = Round(
      Uri.decodeComponent(phrase),
      gameContainer.game.players.keys.toList(),
    );

    for (final channel in gameContainer.channels.values) {
      channel.sink.add(jsonEncode(gameContainer.round?.toJson()));
      gameContainer.round?.getUpdateStream().listen(
        (data) => channel.sink.add(jsonEncode(data)),
      );
    }

    print('Started game $gameId');
    return Response.ok(gameId);
  }

  /// Add player sub phrase
  @Route.post('/game/phrase/<gameId>/<playerId>/<phrase>')
  Response addSubPhrase(Request _, String gameId, String playerId, String phrase) {
    final decodedPhrase = Uri.decodeComponent(phrase);

    final gameContainer = games[gameId];
    if (gameContainer == null) return Response.notFound(gameId);
    final player = gameContainer.game.players[playerId];
    if (player == null) return Response.notFound(gameId);

    gameContainer.round?.addPlayerSubPhrase(playerId, decodedPhrase);

    print('Added phrase "$decodedPhrase" to ${player.name} in $gameId');
    return Response.ok(null);
  }

  /// End the game
  @Route.delete('/game/<gameId>')
  Response endGame(Request _, String gameId) {
    final gameContainer = games[gameId];
    if (gameContainer == null) return Response.notFound(gameId);

    if (gameContainer.game.isStarted == false) return Response.ok(false);

    final scores = gameContainer.round!.scoreRound();
    gameContainer.game.incrementScores(scores);
    gameContainer.game.end();

    print('$gameId ended');
    return Response.ok(gameId);
  }

  Router get router => _$PhrazzleCentralRouter(this);
}
