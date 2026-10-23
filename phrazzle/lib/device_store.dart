import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class DeviceStore {
  final String deviceId;
  final String instanceId;

  DeviceStore._internal(this.deviceId, this.instanceId);

  factory DeviceStore(SharedPreferencesWithCache preferences) {
    var storedDeviceId = preferences.getString('DEVICE_ID');
    if (storedDeviceId == null) {
      storedDeviceId = Uuid().v4();
      preferences.setString('DEVICE_ID', storedDeviceId);
    }
    return DeviceStore._internal(storedDeviceId, Uuid().v4());
  }
}