import 'package:flutter/material.dart';
import 'package:phrazzle/connected_game.dart';

class Scores extends StatelessWidget {
  final ConnectedGame connectedGame;
  final void Function() onLeaveGame;

  const Scores(this.connectedGame, this.onLeaveGame, {super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: connectedGame.game.players.length,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              children: [
                for (final playerId in connectedGame.game.playerIds)
                  Column(
                    crossAxisAlignment: .start,
                    children: [
                      Row(
                        mainAxisAlignment: .center,
                        spacing: 100,
                        children: [
                          Column(
                            children: [
                              Text(
                                'Player',
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 20,
                                ),
                              ),
                              Text(
                                connectedGame.game.players[playerId]!.name,
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
                                connectedGame.game.players[playerId]!.score
                                    .toString(),
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                        ],
                      ),

                      Divider(),
                      Text(
                        connectedGame.round!.initialPhrase,
                        style: TextStyle(color: Colors.cyan, fontSize: 24),
                      ),
                      Expanded(
                        child: ListView(
                          children: [
                            for (final phrase
                                in connectedGame.round!.phrases[playerId]!)
                              Text(phrase, style: TextStyle(fontSize: 20),),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          TabBar(
            tabs: [
              for (final player in connectedGame.game.players.values)
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
