import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceStorage {
  final SharedPreferencesWithCache _preferences;

  final String deviceId;
  final String instanceId;

  static const String userIdKey = 'USER_ID';
  String? get userId => _preferences.getString(userIdKey);
  set userId(String? value) {
    if (value == null) {
      _preferences.remove(userIdKey);
    } else {
      _preferences.setString(userIdKey, value);
    }
  }

  static const String lastGameIdKey = 'LAST_Game_ID';
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

  bool get skipLogin => _preferences.getBool('SKIP_LOGIN') ?? false;
  set skipLogin(bool value) => _preferences.setBool('SKIP_LOGIN', value);

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