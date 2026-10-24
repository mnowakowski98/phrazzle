import 'package:phrazzle_central/stores/user_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class VolatileUserStore extends UserStore {
  @override
  User createUser(User user) => cacheUser(User.newId(user));

  @override
  User? getUser(String id) => cachedUser(id);

  @override
  Iterable<User> get users => cachedUsers;

  @override
  User updateUser(User user) {
    final existing = cachedUser(user.id);
    if (existing == null) throw StateError('Tried to update invalid user ${user.name} (${user.id})');
    cacheUser(user);
    return user;
  }

  @override
  User deleteUser(User user) {
    final existing = cachedUser(user.id);
    if (existing == null) throw StateError('Tried to delete invalid user ${user.name} (${user.id})');
    return uncache(user.id)!;
  }
}