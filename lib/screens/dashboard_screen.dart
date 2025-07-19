import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/device_info_provider.dart';
import '../widgets/loading_animation.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deviceInfo = Provider.of<DeviceInfoProvider>(context);
    if (!deviceInfo.loading && deviceInfo.batteryLevel == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        deviceInfo.fetchDeviceInfo();
      });
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: Center(
        child: deviceInfo.loading
            ? const LoadingAnimation()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Battery:  ${deviceInfo.batteryLevel ?? "-"}%'),
                  Text('Device: ${deviceInfo.deviceName ?? "-"}'),
                  Text('OS Version: ${deviceInfo.osVersion ?? "-"}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pushNamed(context, '/sensor'),
                    child: const Text('Go to Sensor Info'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: deviceInfo.fetchDeviceInfo,
                    child: const Text('Refresh'),
                  ),
                ],
              ),
      ),
    );
  }
} 