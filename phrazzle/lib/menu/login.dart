import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Login extends StatelessWidget {
  final Iterable<User> storedUsers;

  final void Function(User user) onCreateUser;
  final void Function(User user) onLogin;

  const Login(
    this.storedUsers, {
    required this.onCreateUser,
    required this.onLogin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: .start,
      children: [
        Text('Create user', style: TextStyle(color: Colors.teal, fontSize: 20)),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: UserTile(
            User.info(''),
            forceEdit: true,
            onEditingEnd: onCreateUser,
          ),
        ),
        if (storedUsers.isNotEmpty) Expanded(
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
                      for (final user in storedUsers)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton(
                            style: ButtonStyle(alignment: .centerStart),
                            onPressed: () => onLogin(user),
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
        Divider(),
        Center(
          child: OutlinedButton(
            onPressed: () => onLogin(User.anonymous()),
            child: Text('Play offline', style: TextStyle(color: Colors.blueGrey),),
          ),
        ),
      ],
    );
  }
}
