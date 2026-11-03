import 'package:drift/drift.dart';
import 'package:phrazzle_central/database.dart' show AppDatabase, UsersCompanion;
import 'package:phrazzle_central/stores/user_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class DriftUserStore implements UserStore {
  final AppDatabase _database;

  DriftUserStore(this._database);

  @override
  Future<Iterable<User>> get users async => (await _database.select(_database.users).get()).map((user) => User(user.uuid, user.name));

  @override
  Future<User> createUser(User user) async {
    user = User.newId(user);
    await _database.into(_database.users).insert(UsersCompanion.insert(uuid: Value(user.id), name: user.name));
    return user;
  }

  @override
  Future<User?> getUser(String id) async {
    final query = _database.select(_database.users)..where((user) => user.uuid.equals(id));
    final dbUser = await query.getSingleOrNull();
    if (dbUser == null) return null;
    return User(dbUser.uuid, dbUser.name);
  }

  @override
  Future<User> updateUser(User user) async {
    await (_database.update(_database.users)
      ..where((tableUser) => tableUser.uuid.equals(user.id)))
      .write(UsersCompanion(uuid: Value(user.id), name: Value(user.name)));
    return user;
  }

  @override
  Future<User> deleteUser(User user) async {
    await (_database.delete(_database.users)
      ..where((tableUser) => tableUser.uuid.equals(user.id)))
      .go();
    return user;
  }
}