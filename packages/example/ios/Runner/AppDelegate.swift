import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    // Lets the integration tests tell the simulator apart from a device
    // (MediaPipe-backed detectors crash on the simulator, so the tests
    // skip themselves there).
    let channel = FlutterMethodChannel(
      name: "example/simulator",
      binaryMessenger: engineBridge.applicationRegistrar.messenger()
    )
    channel.setMethodCallHandler { call, result in
      if call.method == "isSimulator" {
        #if targetEnvironment(simulator)
        result(true)
        #else
        result(false)
        #endif
      } else {
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
