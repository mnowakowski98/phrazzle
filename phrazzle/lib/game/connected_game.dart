import 'package:flutter/material.dart';
import 'package:phrazzle/env.dart';

import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;

import 'package:phrazzle/game/game.dart';
import 'package:phrazzle_lib/phrazzle.dart' show GameInfo, PhraseValidationInfo, Phrazzle, User;

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

  void updateUsers(Set<String> playerIds) async {
    final newUsers = <String, User>{};
    for (final playerId in playerIds) {
      if (playerUsers.containsKey(playerId)) continue;
      final userResponse = await http.get(Uri.parse('${Env.centralUrl}/player/$playerId/user'));
      final user = User.fromJsonString(userResponse.body);
      newUsers[playerId] = user;
    }
    
    setState(() {
      playerUsers.removeWhere((key, _) => playerIds.contains(key) == false);
      playerUsers.addAll(newUsers);
    });
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
      final game = Phrazzle.fromInfo(GameInfo.fromJsonString(data));
      updateUsers(game.info.players);
      setState(() => this.game = game);
    }));

    channel.sink.add(widget.user.jsonString);

    channel.sink.done.whenComplete(() {
      setState(() => this.channel = null);
      widget.leaveGame();
    });

    setState(() => this.channel = channel);
  }

  void disconnect() {
    if (game.info.isStarted == false) {
      http.delete(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/player/${widget.playerId}'));
    }
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

  void enterPhrase(BuildContext context, String phrase) async {
    final response = await http.post(Uri.parse('${Env.centralUrl}/game/${widget.gameId}/player/${widget.playerId}/phrase/$phrase'));
    if (context.mounted == false) return;

    final validationInfo = PhraseValidationInfo.fromJsonString(response.body);
    final toast = ScaffoldMessenger.of(context);

    final toastPhrase = phrase.length <= 10 ? '"$phrase"' : '"${phrase.substring(0, 10)}..."';

    if (validationInfo.isValid) {
      toast.showSnackBar(
        SnackBar(
          behavior: .floating,
          backgroundColor: Colors.lightGreen,
          content: Text(
            'Submitted $toastPhrase',
          ),
        ),
      );
    } else {
      toast.showSnackBar(
        SnackBar(
          behavior: .floating,
          backgroundColor: Colors.red,
          content: Text('Rejected $toastPhrase'),
        ),
      );
    }
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
  void dispose() {
    channel?.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Game(
            widget.playerId,
            game.info,
            playerUsers,
            startGame: startGame,
            leaveGame: disconnect,
            startRound: startRound,
            enterPhrase: (phrase) => enterPhrase(context, phrase),
            endRound: lockEntry,
            child: game.info.isStarted == false ? Column(children: [
              Text('Game code', style: TextStyle(color: Colors.teal, fontSize: 20),),
              Text(gameCode.toUpperCase(), style: TextStyle(color: Colors.cyan, fontSize: 24),)
            ]) : null,
          ),
        ),
      ],
    );
  }
}