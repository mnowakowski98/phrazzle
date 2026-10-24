import 'package:phrazzle_lib/phrazzle.dart';

abstract class UserStore {
  final _usersCache = <String, User>{};
  // TODO: Restrict these to implementors somehow
  User? cachedUser(String id) => _usersCache[id];
  Iterable<User> get cachedUsers => _usersCache.values;
  User? uncache(String id) => _usersCache.remove(id);
  User cacheUser(User user) {
    if (user.id.isEmpty) throw ArgumentError('Attempted to cache empty user ${user.name}');
    _usersCache[user.id] = user;
    return user;
  }

  User createUser(User user);
  User? getUser(String id);
  Iterable<User> get users;
  User updateUser(User user);
  User deleteUser(User user);
}