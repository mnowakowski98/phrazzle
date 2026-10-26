import 'package:flutter/material.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Scores extends StatelessWidget {
  final Round round;
  final Map<String, User> users;

  final void Function() onLeaveGame;

  const Scores(this.round, this.users, this.onLeaveGame, {super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: round.scores.length,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                for (final playerId in round.scores.keys)
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        mainAxisAlignment: .center,
                        spacing: 100,
                        children: [
                          if (users[playerId]!.name.isNotEmpty) Column(
                            children: [
                              Text(
                                'Player',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                users[playerId]!.name,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              Text(
                                'Score',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 18,
                                ),
                              ),
                              Text(
                                round.scores[playerId]!.toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(),
                      Text(
                        round.phrase,
                        style: TextStyle(color: Colors.cyan, fontSize: 24),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            for (final phrase
                                in round.phraseGroups[playerId]!.phrases)
                              Text(phrase, style: TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          if (round.scores.length > 1) TabBar(
            tabs: [
              for (final player in users.values)
                Tab(text: player.name),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(onPressed: onLeaveGame, child: Text('Leave game')),
          )
        ],
      ),
    );
  }
}
