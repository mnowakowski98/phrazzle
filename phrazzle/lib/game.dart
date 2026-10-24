import 'package:flutter/material.dart';
import 'package:phrazzle/device_store.dart';

import 'package:phrazzle_lib/phrazzle.dart';

class Game extends StatelessWidget {
  final DeviceStorage deviceStore;
  final Phrazzle game;

  const Game(this.deviceStore, this.game, {super.key});

  @override
  Widget build(BuildContext context) {
    return Placeholder();
  }
}
