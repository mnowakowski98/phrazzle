import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phrazzle_lib/phrazzle.dart';

class UserTile extends StatefulWidget {
  final User user;

  final bool allowEdit;
  final bool forceEdit;

  final void Function(User user)? onEditingEnd;
  
  const UserTile(
    this.user, {
    this.allowEdit = false,
    this.forceEdit = false,
    this.onEditingEnd,
    super.key,
  });

  @override
  State<UserTile> createState() => _UserTileState();
}

class _UserTileState extends State<UserTile> {
  var isEditingName = false;
  var editingName = '';

  void endEditing() {
    final onEditingEnd = widget.onEditingEnd;
    if (onEditingEnd != null) onEditingEnd(User.info(editingName));
    if (widget.forceEdit == false) isEditingName = false;
  }

  final _nameEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.forceEdit) isEditingName = true;
    _nameEditingController.addListener(() => editingName = _nameEditingController.text);
  }

  @override
  void dispose() {
    _nameEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isEditingName) {
      return Row(children: [
          Expanded(
            child: Focus(
              onKeyEvent: (node, event) {
                if (event is KeyUpEvent || event.logicalKey != .enter) {
                    return .ignored;
                  }
                  endEditing();
                  return .handled;
              },
              child: TextField(
                controller: _nameEditingController,
                decoration: InputDecoration(hintText: 'Display name'),
              ),
            ),
          ),
        IconButton(onPressed: endEditing, icon: Icon(Icons.check))
      ]);
    }

    return Text(widget.user.name, style: TextStyle(color: Colors.cyan, fontSize: 20),);
  }
}