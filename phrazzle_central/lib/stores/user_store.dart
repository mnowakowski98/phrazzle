import 'package:phrazzle_lib/phrazzle.dart';

class UserStore {
  final _users = <String, User>{};

  Future<User> createUser(User user) async {
    final newUser = User.newId(user);
    _users[newUser.id] = newUser;
    return newUser;
  }

  Future<User?> getUser(String id) async => _users[id];

  Future<Iterable<User>> get users async => _users.values;

  Future<User> updateUser(User user) async {
    final existing = _users[user.id];
    if (existing == null) throw StateError('Tried to update invalid user ${user.name} (${user.id})');
    _users[user.id] = user;
    return user;
  }

  Future<User> deleteUser(User user) async {
    final existing = _users[user.id];
    if (existing == null) throw StateError('Tried to delete invalid user ${user.name} (${user.id})');
    return _users.remove(user.id)!;
  }
}