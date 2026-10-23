import 'package:flutter/material.dart';

class MainMenu extends StatefulWidget {
  final String initialDisplayName;

  const MainMenu(this.initialDisplayName, {super.key});

  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  var playerNameText = '';
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    setState(() {
      _nameController.text = widget.initialDisplayName;
      playerNameText = widget.initialDisplayName;
    });
    _nameController.addListener(() => setState(() => playerNameText = _nameController.text));
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {      
      return Column(
        children: [
          TextField(
            controller: _nameController, decoration: InputDecoration(hintText: 'Display name'),
            textAlign: .center,
            style: TextStyle(fontSize: 24),
          ),
        ],
      );
  }
}