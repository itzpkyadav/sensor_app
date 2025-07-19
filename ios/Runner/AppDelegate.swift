import Flutter
import UIKit
import AVFoundation
import CoreMotion

@main
@objc class AppDelegate: FlutterAppDelegate {
  let motionManager = CMMotionManager()
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
    let deviceInfoChannel = FlutterMethodChannel(name: "device_info_channel", binaryMessenger: controller.binaryMessenger)
    let sensorChannel = FlutterMethodChannel(name: "sensor_channel", binaryMessenger: controller.binaryMessenger)
    let gyroEventChannel = FlutterEventChannel(name: "gyroscope_event_channel", binaryMessenger: controller.binaryMessenger)

    deviceInfoChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "getBatteryLevel":
        UIDevice.current.isBatteryMonitoringEnabled = true
        let batteryLevel = Int(UIDevice.current.batteryLevel * 100)
        result(batteryLevel)
      case "getDeviceName":
        result(UIDevice.current.name)
      case "getOSVersion":
        result(UIDevice.current.systemVersion)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    sensorChannel.setMethodCallHandler { (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "toggleFlashlight":
        guard let args = call.arguments as? [String: Any], let on = args["on"] as? Bool else {
          result(FlutterError(code: "INVALID_ARGS", message: "Missing 'on' argument", details: nil))
          return
        }
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else {
          result(FlutterError(code: "NO_TORCH", message: "Device has no torch", details: nil))
          return
        }
        do {
          try device.lockForConfiguration()
          device.torchMode = on ? .on : .off
          device.unlockForConfiguration()
          result(on)
        } catch {
          result(FlutterError(code: "TORCH_ERROR", message: error.localizedDescription, details: nil))
        }
      case "getGyroscopeData":
        result(FlutterMethodNotImplemented)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    gyroEventChannel.setStreamHandler(GyroStreamHandler(motionManager: motionManager))

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}

class GyroStreamHandler: NSObject, FlutterStreamHandler {
  let motionManager: CMMotionManager
  var timer: Timer?

  init(motionManager: CMMotionManager) {
    self.motionManager = motionManager
  }

  func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    if motionManager.isGyroAvailable {
      motionManager.gyroUpdateInterval = 0.1
      motionManager.startGyroUpdates()
      timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
        if let data = self.motionManager.gyroData {
          let dict: [String: Double] = [
            "x": data.rotationRate.x,
            "y": data.rotationRate.y,
            "z": data.rotationRate.z
          ]
          events(dict)
        }
      }
    }
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    motionManager.stopGyroUpdates()
    timer?.invalidate()
    timer = nil
    return nil
  }
}
