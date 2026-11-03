import 'dart:convert';

import 'package:phrazzle_central/stores/user_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'users.g.dart';

class Users {
  final UserStore userStore;

  Users(this.userStore);

  @Route.post('/user')
  Future<Response> createUser(Request request) async {
    final body = await request.readAsString();
    final user = User.fromJsonString(body);
    return Response.ok((await userStore.createUser(user)).jsonString);
  }

  @Route.get('/user/<id>')
  Future<Response> getUser(Request _, String id) async {
    final user = await userStore.getUser(id);
    if (user == null) return Response.notFound(id);
    return Response.ok(user.jsonString);
  }

  @Route.get('/user')
  Future<Response> getUsers(Request _) async {
    final users = await userStore.users;
    return Response.ok(jsonEncode(users.map((user) => user.toJson())));
  }

  @Route.put('/user')
  Future<Response> updateUser(Request request) async {
    final body = await request.readAsString();
    final newUser = User.fromJsonString(body);
    final existingUser = await userStore.getUser(newUser.id);
    if (existingUser == null) return Response.notFound(newUser.id);
    return Response.ok((await userStore.updateUser(newUser)).jsonString); 
  }

  @Route.delete('/user/<id>')
  Future<Response> deleteUser(Request _, String id)  async {
    final user = await userStore.getUser(id);
    if (user == null) return Response.notFound(id);
    return Response.ok((await userStore.deleteUser(user)).jsonString);
  }

  Router get router => _$UsersRouter(this);
}