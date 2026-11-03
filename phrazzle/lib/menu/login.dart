import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Login extends StatefulWidget {
  final String? lastUserId;
  final Iterable<User> storedUsers;
  final bool autoLogin;

  final void Function(User user) onCreateUser;
  final void Function(User user, bool autoLogin) onLogin;

  const Login(
    this.lastUserId,
    this.storedUsers,
    this.autoLogin, {
    required this.onCreateUser,
    required this.onLogin,
    super.key,
  });

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  var autoLogin = true;

  @override
  void initState() {
    super.initState();
    autoLogin = widget.autoLogin;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Center(child: Text('Phrazzle', style: TextStyle(color: Colors.teal, fontSize: 28, fontWeight: .bold),),),
        Divider(),
        Text('Create user', style: TextStyle(color: Colors.teal, fontSize: 20)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: UserTile(
            User.info(''),
            forceEdit: true,
            onEditingEnd: widget.onCreateUser,
          ),
        ),
        if (widget.storedUsers.isNotEmpty) Expanded(
          child: Column(
            crossAxisAlignment: .start,
            children: [
              Divider(),
              Text('Login', style: TextStyle(color: Colors.teal, fontSize: 20)),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: [
                      for (final user in widget.storedUsers)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ButtonStyle(alignment: .centerStart),
                            onPressed: () => widget.onLogin(user, autoLogin),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: UserTile(user),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Checkbox(value: autoLogin, onChanged: (value) => setState(() => autoLogin = value!)),
            Expanded(child: Text('Remember choice'))
          ],
        ),
        Divider(),
        Center(
          child: OutlinedButton(
            style: ButtonStyle(),
            onPressed: () => widget.onLogin(User.anonymous(), autoLogin),
            child: Text('Play offline', style: TextStyle(color: Colors.blueGrey),),
          ),
        ),
      ],
    );
  }
}
