// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$UsersRouter(Users service) {
  final router = Router();
  router.add('POST', r'/user', service.createUser);
  router.add('GET', r'/user/<id>', service.getUser);
  router.add('GET', r'/user', service.getUsers);
  router.add('PUT', r'/user', service.updateUser);
  router.add('DELETE', r'/user/<id>', service.deleteUser);
  return router;
}
