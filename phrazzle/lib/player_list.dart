import 'package:flutter/material.dart';
import 'package:phrazzle/player.dart';
import 'package:phrazzle/player_tile.dart';

class PlayerList extends StatefulWidget {
  final List<Player> players;

  final bool allowEdit;
  final void Function(String name)? onPlayerAdd;
  final void Function()? onDone;

  const PlayerList(
    this.players, {
    super.key,
    this.allowEdit = false,
    this.onPlayerAdd,
    this.onDone,
  });

  @override
  State<PlayerList> createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  var inputText = '';

  @override
  build(BuildContext context) {
    return Expanded(
      child: ListView(
        children: [
          ListTile(
            title: Text('Players'),
            titleTextStyle: TextStyle(
              fontWeight: .bold,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
            subtitle: Row(
              crossAxisAlignment: .end,
              children: [
                Expanded(
                  child: TextField(onChanged: (final text) => inputText = text),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onPlayerAdd != null) {
                      widget.onPlayerAdd!(inputText);
                    }
                  },
                  child: Text('Add'),
                ),
                TextButton(
                  onPressed: () {
                    if (widget.onDone != null) {
                      widget.onDone!();
                    }
                  },
                  child: Text('Done'),
                ),
              ],
            ),
          ),
          for (final player in widget.players) PlayerTile(player),
        ],
      ),
    );
  }
}
