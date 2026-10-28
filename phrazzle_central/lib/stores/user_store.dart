import 'package:phrazzle_lib/phrazzle.dart';

class UserStore {
  final _users = <String, User>{};

  User createUser(User user) {
    final newUser = User.newId(user);
    _users[newUser.id] = newUser;
    return newUser;
  }

  User? getUser(String id) => _users[id];

  Iterable<User> get users => _users.values;

  User updateUser(User user) {
    final existing = _users[user.id];
    if (existing == null) throw StateError('Tried to update invalid user ${user.name} (${user.id})');
    _users[user.id] = user;
    return user;
  }

  User deleteUser(User user) {
    final existing = _users[user.id];
    if (existing == null) throw StateError('Tried to delete invalid user ${user.name} (${user.id})');
    return _users.remove(user.id)!;
  }
}