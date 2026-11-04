import Flutter
import MLKitVision
import MLKitFaceDetection
import google_mlkit_commons

@objc
public class GoogleMlKitFaceDetectionPlugin: NSObject, FlutterPlugin {
  private var instances: [String: FaceDetector] = [:]

  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(
      name: "google_mlkit_face_detector",
      binaryMessenger: registrar.messenger()
    )
    let instance = GoogleMlKitFaceDetectionPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "vision#startFaceDetector":
      handleDetection(call: call, result: result)
    case "vision#closeFaceDetector":
      if let args = call.arguments as? [String: Any], let uid = args["id"] as? String {
        instances.removeValue(forKey: uid)
      }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  private func initialize(call: FlutterMethodCall) -> FaceDetector? {
    guard let args = call.arguments as? [String: Any],
          let dictionary = args["options"] as? [String: Any] else {
      return nil
    }
    let options = FaceDetectorOptions()
    options.classificationMode = (dictionary["enableClassification"] as? NSNumber)?.boolValue == true ? .all : .none
    options.landmarkMode = (dictionary["enableLandmarks"] as? NSNumber)?.boolValue == true ? .all : .none
    options.contourMode = (dictionary["enableContours"] as? NSNumber)?.boolValue == true ? .all : .none
    options.isTrackingEnabled = (dictionary["enableTracking"] as? NSNumber)?.boolValue ?? false
    if let minFaceSize = dictionary["minFaceSize"] as? NSNumber {
      options.minFaceSize = CGFloat(minFaceSize.floatValue)
    }
    let mode = dictionary["mode"] as? String ?? "fast"
    options.performanceMode = mode == "accurate" ? .accurate : .fast
    return FaceDetector.faceDetector(options: options)
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

    let detector: FaceDetector
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

    detector.process(image) { faces, error in
      if let error = error as NSError? {
        result(FlutterError(code: "Error \(error.code)", message: error.domain, details: error.localizedDescription))
        return
      }
      guard let faces = faces else {
        result([])
        return
      }
      let faceData = faces.map { face -> [String: Any] in
        self.faceToDictionary(face)
      }
      result(faceData)
    }
  }

  private func faceToDictionary(_ face: Face) -> [String: Any] {
    let data: [String: Any] = [
      "rect": [
        "left": face.frame.origin.x,
        "top": face.frame.origin.y,
        "right": face.frame.origin.x + face.frame.size.width,
        "bottom": face.frame.origin.y + face.frame.size.height
      ],
      "headEulerAngleX": face.hasHeadEulerAngleX ? face.headEulerAngleX as Any : NSNull(),
      "headEulerAngleY": face.hasHeadEulerAngleY ? face.headEulerAngleY as Any : NSNull(),
      "headEulerAngleZ": face.hasHeadEulerAngleZ ? face.headEulerAngleZ as Any : NSNull(),
      "smilingProbability": face.hasSmilingProbability ? face.smilingProbability as Any : NSNull(),
      "leftEyeOpenProbability": face.hasLeftEyeOpenProbability ? face.leftEyeOpenProbability as Any : NSNull(),
      "rightEyeOpenProbability": face.hasRightEyeOpenProbability ? face.rightEyeOpenProbability as Any : NSNull(),
      "trackingId": face.hasTrackingID ? face.trackingID as Any : NSNull(),
      "landmarks": [
        "bottomMouth": getLandmarkPosition(face, landmark: .mouthBottom),
        "rightMouth": getLandmarkPosition(face, landmark: .mouthRight),
        "leftMouth": getLandmarkPosition(face, landmark: .mouthLeft),
        "rightEye": getLandmarkPosition(face, landmark: .rightEye),
        "leftEye": getLandmarkPosition(face, landmark: .leftEye),
        "rightEar": getLandmarkPosition(face, landmark: .rightEar),
        "leftEar": getLandmarkPosition(face, landmark: .leftEar),
        "rightCheek": getLandmarkPosition(face, landmark: .rightCheek),
        "leftCheek": getLandmarkPosition(face, landmark: .leftCheek),
        "noseBase": getLandmarkPosition(face, landmark: .noseBase)
      ],
      "contours": [
        "face": getContourPoints(face, contour: .face),
        "leftEyebrowTop": getContourPoints(face, contour: .leftEyebrowTop),
        "leftEyebrowBottom": getContourPoints(face, contour: .leftEyebrowBottom),
        "rightEyebrowTop": getContourPoints(face, contour: .rightEyebrowTop),
        "rightEyebrowBottom": getContourPoints(face, contour: .rightEyebrowBottom),
        "leftEye": getContourPoints(face, contour: .leftEye),
        "rightEye": getContourPoints(face, contour: .rightEye),
        "upperLipTop": getContourPoints(face, contour: .upperLipTop),
        "upperLipBottom": getContourPoints(face, contour: .upperLipBottom),
        "lowerLipTop": getContourPoints(face, contour: .lowerLipTop),
        "lowerLipBottom": getContourPoints(face, contour: .lowerLipBottom),
        "noseBridge": getContourPoints(face, contour: .noseBridge),
        "noseBottom": getContourPoints(face, contour: .noseBottom),
        "leftCheek": getContourPoints(face, contour: .leftCheek),
        "rightCheek": getContourPoints(face, contour: .rightCheek)
      ]
    ]
    return data
  }

  private func getLandmarkPosition(_ face: Face, landmark: FaceLandmarkType) -> Any {
    guard let landmarkObj = face.landmark(ofType: landmark) else { return NSNull() }
    return [NSNumber(value: landmarkObj.position.x), NSNumber(value: landmarkObj.position.y)]
  }

  private func getContourPoints(_ face: Face, contour: FaceContourType) -> Any {
    guard let contourObj = face.contour(ofType: contour) else { return NSNull() }
    return contourObj.points.map { [NSNumber(value: $0.x), NSNumber(value: $0.y)] }
  }
}
