import 'dart:convert';

import 'package:phrazzle_central/stores/user_store.dart';
import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

part 'users.g.dart';

class Users {
  final UserStore userStore;

  Users(this.userStore);

  @Route.post('/users')
  Future<Response> createUser(Request request) async {
    final body = await request.readAsString();
    final user = User.fromJsonString(body);
    return Response.ok(userStore.createUser(user).jsonString);
  }

  @Route.get('/users/<id>')
  Response getUser(Request _, String id) {
    final user = userStore.getUser(id);
    if (user == null) return Response.notFound(id);
    return Response.ok(user.jsonString);
  }

  @Route.get('/users')
  Response getUsers(Request _) {
    return Response.ok(jsonEncode(userStore.users.map((user) => user.json)));
  }

  @Route.put('/users')
  Future<Response> updateUser(Request request) async {
    final body = await request.readAsString();
    final newUser = User.fromJsonString(body);
    final existingUser = userStore.getUser(newUser.id);
    if (existingUser == null) return Response.notFound(newUser.id);
    return Response.ok(userStore.updateUser(newUser).jsonString); 
  }

  @Route.delete('/users/<id>')
  Response deleteUser(Request _, String id)  {
    final user = userStore.getUser(id);
    if (user == null) return Response.notFound(id);
    return Response.ok(userStore.deleteUser(user).jsonString);
  }

  Router get router => _$UsersRouter(this);
}