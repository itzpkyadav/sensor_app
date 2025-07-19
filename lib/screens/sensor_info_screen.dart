import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sensor_provider.dart';
import '../widgets/loading_animation.dart';

class SensorInfoScreen extends StatelessWidget {
  const SensorInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensor = Provider.of<SensorProvider>(context);
    sensor.startGyroStream();
    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Info')),
      body: Center(
        child: sensor.loading
            ? const LoadingAnimation()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Flashlight: ${sensor.flashOn ? "ON" : "OFF"}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: sensor.toggleFlashlight,
                    child: Text(sensor.flashOn ? 'Turn OFF' : 'Turn ON'),
                  ),
                  const SizedBox(height: 24),
                  Text('Gyroscope: ${sensor.gyroData != null ? sensor.gyroData.toString() : "No data"}'),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to Dashboard'),
                  ),
                ],
              ),
      ),
    );
  }
} 