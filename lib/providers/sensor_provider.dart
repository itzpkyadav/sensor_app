import 'package:flutter/material.dart';
import '../services/sensor_service.dart';

class SensorProvider extends ChangeNotifier {
  final SensorService _service = SensorService();
  bool flashOn = false;
  bool loading = false;
  Map<String, dynamic>? gyroData;
  Stream<dynamic>? _gyroStream;

  Future<void> toggleFlashlight() async {
    loading = true;
    notifyListeners();
    final result = await _service.toggleFlashlight(!flashOn);
    flashOn = result ?? flashOn;
    loading = false;
    notifyListeners();
  }

  void startGyroStream() {
    _gyroStream ??= _service.getGyroscopeStream();
    _gyroStream!.listen((event) {
      if (event is Map) {
        gyroData = Map<String, dynamic>.from(event);
        notifyListeners();
      }
    });
  }
} 