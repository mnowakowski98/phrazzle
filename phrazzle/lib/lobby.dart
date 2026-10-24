// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';

// import 'package:http/http.dart' as http;
// import 'package:phrazzle/connected_game.dart';
// import 'package:phrazzle/env.dart';

// import 'package:phrazzle/player_list.dart';

// class Lobby extends StatefulWidget {
//   final ConnectedGame connectedGame;

//   const Lobby(this.connectedGame, {super.key});

//   @override
//   State<Lobby> createState() => _LobbyState();
// }

// class _LobbyState extends State<Lobby> {
//   String startingPhrase = '';
//   bool get allowStart => startingPhrase.isNotEmpty;

//   void startGame() async {
//     await http.put(Uri.parse('${Env.centralUrl}/game/${widget.connectedGame.gameId}/$startingPhrase'));
//   }

//   void leaveGame() async {
//     await http.delete(Uri.parse('${Env.centralUrl}/game/${widget.connectedGame.gameId}/${widget.connectedGame.playerId}'));
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         PlayerList(widget.connectedGame, 'Lobby', false),
//         Divider(),
//         Text('Game code'),
//         Text(widget.connectedGame.gameId.substring(0, 5).toUpperCase(), style: TextStyle(fontSize: 18, color: Colors.cyan)),
//         Divider(),
//         Focus(
//           child: TextField(
//             decoration: InputDecoration(hintText: 'Starting phrase'),
//             onChanged: (value) => setState(() => startingPhrase = value),
//           ),
//           onKeyEvent: (node, event) {
//             if (event is KeyUpEvent || event.logicalKey != .enter) {
//               return .ignored;
//             }
//             if (allowStart) startGame();
//             return .handled;
//           },
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Row(
//             mainAxisAlignment: .spaceEvenly,
//             children: [
//               TextButton(onPressed: leaveGame, child: Text('Leave', style: TextStyle(color: Colors.red),)),
//               ElevatedButton(
//                 onPressed: allowStart ? startGame : null,
//                 child: Text('Start'),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }
