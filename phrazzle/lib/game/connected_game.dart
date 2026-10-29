import 'package:flutter/material.dart';
import 'package:phrazzle/env.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/game/game.dart';
import 'package:phrazzle_lib/phrazzle.dart' show Phrazzle, User;

/// State manager for games that connect to the central app
class ConnectedGame extends StatefulWidget {
  final String gameId;
  final String playerId;
  final User user;

  final void Function() leaveGame;

  const ConnectedGame(
    this.gameId,
    this.playerId,
    this.user,
    this.leaveGame, {
    super.key,
  });

  @override
  State<ConnectedGame> createState() => _ConnectedGameState();
}

class _ConnectedGameState extends State<ConnectedGame> {
  Phrazzle game = Phrazzle();
  WebSocketChannel? channel;

  final playerUsers = <String, User>{};
  var gameCode = '';

  void getGameCode() async {
    final gameCodeResponse = await http.get(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/code'));
    setState(() => gameCode = gameCodeResponse.body);
  }

  void getUsers(Set<String> playerIds) async {
    final newUsers = <String, User>{};
    for (final playerId in playerIds) {
      if (playerUsers.containsKey(playerId)) continue;
      final userResponse = await http.get(Uri.parse('${Env.centralUrl}/player/$playerId/user'));
      final user = User.fromJsonString(userResponse.body);
      newUsers[playerId] = user;
    }
    print('Adding users ${newUsers.keys.toString()}');
    setState(() => playerUsers.addAll(newUsers));
  }

  void connect() async {
    final channel = WebSocketChannel.connect(Uri.parse('${Env.gameUrl}/game/${widget.gameId}/player/${widget.playerId}'));
    try {
      await channel.ready;
    } catch (error) {
      setState(() => this.channel = null);
      widget.leaveGame();
    }

    channel.stream.listen((data) => setState(() {
      final game = Phrazzle.fromJsonString(data);
      if (game.players.length > playerUsers.length) {
        print('Updating users');
        getUsers(game.players);
      }
      setState(() => this.game = game);
    }));

    channel.sink.add(widget.user.jsonString);

    channel.sink.done.whenComplete(() {
      print('Closed connection: ${channel.closeCode} - ${channel.closeReason}');
      setState(() => this.channel = null);
      widget.leaveGame();
    });

    print('Connected to ${widget.gameId} as ${widget.playerId}');
    setState(() => this.channel = channel);
  }

  void disconnect() {
    channel?.sink.close(1000);
    setState(() => channel = null);
    widget.leaveGame();
  }

  void startGame() async {
    await http.post(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/start'));
  }

  void startRound(String phrase) async {
    final createRoundResponse = await http.post(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/round/$phrase'));
    final roundId = createRoundResponse.body;
    await http.put(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/round/$roundId'));
  }

  void enterPhrase(String phrase) async {
    await http.post(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/player/${widget.playerId}/phrase/$phrase'));
  }

  void lockEntry() async {
    await http.put(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/player/${widget.playerId}/lock'));
  }

  @override
  void initState() {
    super.initState();
    connect();
    getGameCode();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Game(
            widget.playerId,
            game,
            playerUsers,
            startGame: startGame,
            leaveGame: disconnect,
            startRound: startRound,
            enterPhrase: enterPhrase,
            endRound: lockEntry,
            child: game.isStarted == false ? Column(children: [
              Text('Game code', style: TextStyle(color: Colors.teal, fontSize: 20),),
              Text(gameCode.toUpperCase(), style: TextStyle(color: Colors.cyan, fontSize: 24),)
            ]) : null,
          ),
        ),
      ],
    );
  }
}