import 'package:phrazzle_lib/phrazzle.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceStorage {
  final SharedPreferencesWithCache _preferences;

  final String deviceId;
  final String instanceId;

  static const String autoLoginKey = 'AUTO_LOGIN';
  bool get autoLogin {
    var value = _preferences.getBool(autoLoginKey);
    if (value == null) {
      value = true;
      _preferences.setBool(autoLoginKey, value);
    }
    return value;
  }
  set autoLogin(bool value) => _preferences.setBool(autoLoginKey, value);

  static const String lastUserIdKey = 'LAST_USER_ID';
  String? get lastUserId => _preferences.getString(lastUserIdKey);
  set lastUserId(String? value) {
    if (value == null) {
      _preferences.remove(lastUserIdKey);
    } else {
      _preferences.setString(lastUserIdKey, value);
    }
  }

  static const String usersKey = 'USERS';
  Iterable<User> get users => _preferences.getStringList('USERS')?.reversed.map((userString) => User.fromJsonString(userString)) ?? [];
  void storeUser(User user) {
    if (user.isUser == false) return;

    final users = this.users.toList();
    final existingUserIndex = users.indexWhere((storedUser) => storedUser.id == user.id);
    if (existingUserIndex >= 0) {
      users.removeAt(existingUserIndex);
      users.add(user);
    } else {
      users.add(user);
    }

    _preferences.setStringList(usersKey, users.map((user) => user.jsonString).toList());
  }

  User? removeUser(String userId) {
    final users = this.users.toList();
    final existingUser = users.singleWhere((storedUser) => storedUser.id == userId, orElse: () => User.blank());
    if (existingUser.id.isEmpty) return null;
    users.remove(existingUser);
    _preferences.setStringList(usersKey, users.map((user) => user.jsonString).toList());
    return existingUser;
  }

  static const String lastGameIdKey = 'LAST_GAME_ID';
  String? get lastGameId => _preferences.getString(lastGameIdKey);
  set lastGameId(String? value) {
    if (value == null) {
      _preferences.remove(lastGameIdKey);
    } else {
      _preferences.setString(lastGameIdKey, value);
    }
  }

  static const String lastPlayerIdKey = 'LAST_PLAYER_ID';
  String? get lastPlayerId => _preferences.getString(lastPlayerIdKey);
  set lastPlayerId(String? value) {
    if (value == null) {
      _preferences.remove(lastPlayerIdKey);
    } else {
      _preferences.setString(lastPlayerIdKey, value);
    }
  }

  DeviceStorage._internal(this._preferences, this.deviceId, this.instanceId);

  factory DeviceStorage(SharedPreferencesWithCache preferences) {
    var storedDeviceId = preferences.getString('DEVICE_ID');
    if (storedDeviceId == null) {
      storedDeviceId = Uuid().v4();
      preferences.setString('DEVICE_ID', storedDeviceId);
    }

    return DeviceStorage._internal(preferences, storedDeviceId, Uuid().v4());
  }
}