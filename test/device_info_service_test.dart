import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sensor_app/services/device_info_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('DeviceInfoService', () {
    const MethodChannel channel = MethodChannel('device_info_channel');
    final DeviceInfoService service = DeviceInfoService();

    setUp(() {
      // Reset the mock handler before each test
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
    });

    test('getBatteryLevel returns mocked value', () async {
      const int mockBatteryLevel = 85;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
        channel,
        (MethodCall methodCall) async {
          if (methodCall.method == 'getBatteryLevel') {
            return mockBatteryLevel;
          }
          return null;
        },
      );

      final int? batteryLevel = await service.getBatteryLevel();
      expect(batteryLevel, mockBatteryLevel);
    });
  });
} 