import 'package:drift/drift.dart';
import 'package:phrazzle_central/database.dart' show AppDatabase, UsersCompanion;
import 'package:phrazzle_central/stores/user_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';

class DriftUserStore implements UserStore {
  final AppDatabase Function() _databaseFunction;

  DriftUserStore(this._databaseFunction);

  @override
  Future<Iterable<User>> get users async {
    final database = _databaseFunction();
    return (await database.select(database.users).get()).map((user) => User(user.uuid, user.name));
  }

  @override
  Future<User> createUser(User user) async {
    final database = _databaseFunction();
    user = User.newId(user);
    await database.into(database.users).insert(UsersCompanion.insert(uuid: user.id, name: user.name));
    return user;
  }

  @override
  Future<User?> getUser(String id) async {
    final database = _databaseFunction();
    final query = database.select(database.users)..where((user) => user.uuid.equals(id));
    final dbUser = await query.getSingleOrNull();
    if (dbUser == null) return null;
    return User(dbUser.uuid, dbUser.name);
  }

  @override
  Future<User> updateUser(User user) async {
    final database = _databaseFunction();
    await (database.update(database.users)
      ..where((tableUser) => tableUser.uuid.equals(user.id)))
      .write(UsersCompanion(uuid: Value(user.id), name: Value(user.name)));
    return user;
  }

  @override
  Future<User> deleteUser(User user) async {
    final database = _databaseFunction();
    await (database.delete(database.users)
      ..where((tableUser) => tableUser.uuid.equals(user.id)))
      .go();
    return user;
  }
}