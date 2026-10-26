import 'package:flutter/material.dart';
import 'package:phrazzle/menu/user_tile.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class Login extends StatelessWidget {
  final void Function(User user) onLogin;
  final void Function() onSkip;

  const Login(this.onLogin, this.onSkip, {super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Column(
            children: [
              Text('Login'),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: UserTile(User.blank(), forceEdit: true, onEditingEnd: onLogin,),
              ),
            ],
          ),
        ),
        TextButton(onPressed: onSkip, child: Text('Skip', style: TextStyle(color: Colors.amber),))
      ],
    );
  }

}