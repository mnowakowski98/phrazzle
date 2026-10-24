// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'users.dart';

// **************************************************************************
// ShelfRouterGenerator
// **************************************************************************

Router _$UsersRouter(Users service) {
  final router = Router();
  router.add('POST', r'/users', service.createUser);
  router.add('GET', r'/users/<id>', service.getUser);
  router.add('GET', r'/users', service.getUsers);
  router.add('PUT', r'/users', service.updateUser);
  router.add('DELETE', r'/users/<id>', service.deleteUser);
  return router;
}
