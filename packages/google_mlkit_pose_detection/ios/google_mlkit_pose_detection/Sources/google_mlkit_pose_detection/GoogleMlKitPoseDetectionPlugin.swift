import Flutter
import MLKitVision
import MLKitPoseDetection
import MLKitPoseDetectionCommon
import MLKitPoseDetectionAccurate
import google_mlkit_commons

@objc
public class GoogleMlKitPoseDetectionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: PoseDetector] = [:]

  private static let landmarkTypeToNumber: [PoseLandmarkType: Int] = [
    .nose: 0,
    .leftEyeInner: 1,
    .leftEye: 2,
    .leftEyeOuter: 3,
    .rightEyeInner: 4,
    .rightEye: 5,
    .rightEyeOuter: 6,
    .leftEar: 7,
    .rightEar: 8,
    .mouthLeft: 9,
    .mouthRight: 10,
    .leftShoulder: 11,
    .rightShoulder: 12,
    .leftElbow: 13,
    .rightElbow: 14,
    .leftWrist: 15,
    .rightWrist: 16,
    .leftPinkyFinger: 17,
    .rightPinkyFinger: 18,
    .leftIndexFinger: 19,
    .rightIndexFinger: 20,
    .leftThumb: 21,
    .rightThumb: 22,
    .leftHip: 23,
    .rightHip: 24,
    .leftKnee: 25,
    .rightKnee: 26,
    .leftAnkle: 27,
    .rightAnkle: 28,
    .leftHeel: 29,
    .rightHeel: 30,
    .leftToe: 31,
    .rightToe: 32
  ]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_pose_detector",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitPoseDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startPoseDetector":
      handleDetection(call: call, result: result)
    case "vision#closePoseDetector":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(call: FlutterMethodCall) -> PoseDetector? {
    guard let args = call.arguments as? [String: Any],
          let optionsDict = args["options"] as? [String: Any] else { return nil }
    let mode = optionsDict["mode"] as? String ?? "stream"
    let detectorMode: PoseDetectorMode = mode == "single" ? .singleImage : .stream
    let model = optionsDict["model"] as? String ?? "base"

    if model == "base" {
      let options = PoseDetectorOptions()
      options.detectorMode = detectorMode
      return PoseDetector.poseDetector(options: options)
    } else {
      let options = AccuratePoseDetectorOptions()
      options.detectorMode = detectorMode
      return PoseDetector.poseDetector(options: options)
    }
  }

  private func handleDetection(call: FlutterMethodCall, result: @escaping FlutterResult) {
    guard let args = call.arguments as? [String: Any],
          let imageData = args["imageData"] as? [String: Any],
          let uid = args["id"] as? String else {
      result(FlutterError(code: "invalid_args", message: "Missing arguments", details: nil))
      return
    }
    guard let image = VisionImage.visionImage(from: imageData) else {
      result(FlutterError(code: "invalid_image", message: "Invalid or missing image data", details: nil))
      return
    }

    let detector: PoseDetector
    if let existing = instances[uid] {
      detector = existing
    } else {
      guard let newDetector = initialize(call: call) else {
        result(FlutterError(code: "invalid_args", message: "Invalid options", details: nil))
        return
      }
      detector = newDetector
      instances[uid] = detector
    }

    detector.process(image) { poses, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let poses = poses, !poses.isEmpty else {
        result([])
        return
      }
      let array = poses.map { pose -> [[String: Any]] in
        pose.landmarks.map { landmark in
          [
            "type": Self.landmarkTypeToNumber[landmark.type] ?? -1,
            "x": landmark.position.x,
            "y": landmark.position.y,
            "z": landmark.position.z,
            "likelihood": landmark.inFrameLikelihood
          ] as [String: Any]
        }
      }
      result(array)
    }
  }
}
