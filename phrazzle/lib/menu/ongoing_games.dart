import 'package:flutter/material.dart';

class OngoingGames extends StatelessWidget {
  const OngoingGames({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('Ongoing games'),
        Expanded(child: ListView(children: [

        ],)),
      ],
    );
  }
}