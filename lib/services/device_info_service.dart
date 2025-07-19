import 'package:flutter/services.dart';

class DeviceInfoService {
  static const MethodChannel _channel = MethodChannel('device_info_channel');

  Future<int?> getBatteryLevel() async {
    final int? batteryLevel = await _channel.invokeMethod<int>('getBatteryLevel');
    return batteryLevel;
  }

  Future<String?> getDeviceName() async {
    final String? deviceName = await _channel.invokeMethod<String>('getDeviceName');
    return deviceName;
  }

  Future<String?> getOSVersion() async {
    final String? osVersion = await _channel.invokeMethod<String>('getOSVersion');
    return osVersion;
  }
} 