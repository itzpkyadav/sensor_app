import 'package:flutter/services.dart';

class SensorService {
  static const MethodChannel _channel = MethodChannel('sensor_channel');
  static const EventChannel _gyroChannel = EventChannel('gyroscope_event_channel');

  Future<bool?> toggleFlashlight(bool on) async {
    final bool? result = await _channel.invokeMethod<bool>('toggleFlashlight', {'on': on});
    return result;
  }

  Stream<dynamic> getGyroscopeStream() {
    return _gyroChannel.receiveBroadcastStream();
  }
} 