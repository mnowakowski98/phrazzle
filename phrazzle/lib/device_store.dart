import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceStorage {
  final SharedPreferencesWithCache _preferences;

  final String deviceId;
  final String instanceId;

  String? get userId => _preferences.getString('USER_ID');
  set userId(String? id) {
    if (id == null) {
      _preferences.remove('USER_ID');
    } else {
      _preferences.setString('USER_ID', id);
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