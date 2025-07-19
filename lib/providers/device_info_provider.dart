import 'package:flutter/material.dart';
import '../services/device_info_service.dart';

class DeviceInfoProvider extends ChangeNotifier {
  final DeviceInfoService _service = DeviceInfoService();
  int? batteryLevel;
  String? deviceName;
  String? osVersion;
  bool loading = false;

  Future<void> fetchDeviceInfo() async {
    loading = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 1500)); // Simulate loading
    batteryLevel = await _service.getBatteryLevel();
    deviceName = await _service.getDeviceName();
    osVersion = await _service.getOSVersion();
    loading = false;
    notifyListeners();
  }
} 