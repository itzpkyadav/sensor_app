package com.itzpkyadav.sensor_app

import android.content.Context
import android.os.BatteryManager
import android.os.Build
import android.hardware.Sensor
import android.hardware.SensorEvent
import android.hardware.SensorEventListener
import android.hardware.SensorManager
import android.content.pm.PackageManager
import android.hardware.camera2.CameraAccessException
import android.hardware.camera2.CameraManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.EventChannel

class MainActivity : FlutterActivity() {
    private val DEVICE_INFO_CHANNEL = "device_info_channel"
    private val SENSOR_CHANNEL = "sensor_channel"
    private val GYROSCOPE_EVENT_CHANNEL = "gyroscope_event_channel"
    private var isFlashOn = false
    private var sensorManager: SensorManager? = null
    private var gyroListener: SensorEventListener? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, DEVICE_INFO_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "getBatteryLevel" -> {
                    val batteryManager = getSystemService(Context.BATTERY_SERVICE) as BatteryManager
                    val batteryLevel = batteryManager.getIntProperty(BatteryManager.BATTERY_PROPERTY_CAPACITY)
                    result.success(batteryLevel)
                }
                "getDeviceName" -> {
                    result.success(Build.MODEL)
                }
                "getOSVersion" -> {
                    result.success(Build.VERSION.RELEASE)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, SENSOR_CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "toggleFlashlight" -> {
                    val on = call.argument<Boolean>("on") ?: false
                    val cameraManager = getSystemService(Context.CAMERA_SERVICE) as CameraManager
                    try {
                        val cameraId = cameraManager.cameraIdList[0]
                        cameraManager.setTorchMode(cameraId, on)
                        isFlashOn = on
                        result.success(isFlashOn)
                    } catch (e: CameraAccessException) {
                        result.error("CAMERA_ERROR", e.localizedMessage, null)
                    }
                }
                "getGyroscopeData" -> {
                    // For simplicity, return not implemented. Real implementation would require event streaming.
                    result.notImplemented()
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, GYROSCOPE_EVENT_CHANNEL).setStreamHandler(
            object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                    sensorManager = getSystemService(Context.SENSOR_SERVICE) as SensorManager
                    val gyroSensor = sensorManager?.getDefaultSensor(Sensor.TYPE_GYROSCOPE)
                    gyroListener = object : SensorEventListener {
                        override fun onSensorChanged(event: SensorEvent) {
                            val data = mapOf(
                                "x" to event.values[0],
                                "y" to event.values[1],
                                "z" to event.values[2]
                            )
                            events?.success(data)
                        }
                        override fun onAccuracyChanged(sensor: Sensor?, accuracy: Int) {}
                    }
                    sensorManager?.registerListener(gyroListener, gyroSensor, SensorManager.SENSOR_DELAY_UI)
                }
                override fun onCancel(arguments: Any?) {
                    sensorManager?.unregisterListener(gyroListener)
                }
            }
        )
    }
}
