import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:phrazzle/env.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class OngoingGames extends StatefulWidget {
  final User user;
  final void Function(String gameId, String playerId) onGameJoin;

  const OngoingGames(this.user, this.onGameJoin, {super.key});

  @override
  State<OngoingGames> createState() => _OngoingGamesState();
}

class _OngoingGamesState extends State<OngoingGames> {
  final activeRecords = <String, PlayerRecord>{};

  Future<void> getActiveGames() async {
    final gamesResponse = await http.get(Uri.parse('${Env.centralUrl}/player/user/${widget.user.id}/active'));
    final recordsJson = jsonDecode(gamesResponse.body) as List<dynamic>;
    final records = recordsJson.map((record) => PlayerRecord.fromJson(record));

    for (final record in records) {
      final gameCodeResponse = await http.get(Uri.parse('${Env.centralUrl}/game/${record.gameId}/code'));
      final code = gameCodeResponse.body;
      setState(() => activeRecords[code] = record);
    }
  }

  @override
  void initState() {
    super.initState();
    getActiveGames();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
        for (final entry in activeRecords.entries)
          ElevatedButton(
            onPressed: () => widget.onGameJoin(entry.key, entry.value.playerId),
            child: Center(
              child: Text(
                entry.key.toUpperCase(),
                style: TextStyle(color: Colors.cyan, fontSize: 18),
              ),
            ),
          )
    ],);
  }
}