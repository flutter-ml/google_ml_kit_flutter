part of 'google_ml_kit.dart';

enum PoseDetectionModel { BasePoseDetector, AccuratePoseDetector }
enum PoseDetectionMode { StaticImage, StreamImage }
enum LandmarkSelectionType { all, specific }

class PoseDetector {
  final PoseDetectorOptions poseDetectorOptions;
  bool _isOpened = false;
  bool _isClosed = false;

  PoseDetector(this.poseDetectorOptions);

  Future<Map<int, PoseLandmark>> processImage(InputImage inputImage) async {
    assert(inputImage != null);
    _isOpened = true;

    List<dynamic> result = await GoogleMlKit.channel
        .invokeMethod("startPoseDetector", <String, dynamic>{
      "options": poseDetectorOptions._detectorOption(),
      "imageData": inputImage._getImageData()
    });

    List<PoseLandmark> poseLandmarks = <PoseLandmark>[];
    if (result != null) {
      poseLandmarks.addAll(result
          .map((item) => PoseLandmark(item["type"], item["x"], item["y"])));
    }

    Map<int, PoseLandmark> map = Map.fromIterable(result,
        key: (item) => item["position"],
        value: (item) => PoseLandmark(item["type"], item["x"], item["y"]));
    print(map);

    return map;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await GoogleMlKit.channel.invokeMethod("closePoseDetector");
      _isClosed = true;
      _isOpened = false;
    }
  }
}

class PoseDetectorOptions {
  final PoseDetectionModel poseDetectionModel;
  final PoseDetectionMode poseDetectionMode;
  final List<int> poseLandmarks;
  final LandmarkSelectionType selectionType;

  PoseDetectorOptions(
      {this.poseDetectionModel = PoseDetectionModel.BasePoseDetector,
        this.poseDetectionMode = PoseDetectionMode.StaticImage,
        this.selectionType = LandmarkSelectionType.all,
        this.poseLandmarks}) {
    if (selectionType == LandmarkSelectionType.specific) {
      assert(poseLandmarks != null);
    }
  }

  Map<String, dynamic> _detectorOption() =>
      <String, dynamic>{
        "detectorType":
        poseDetectionModel == PoseDetectionModel.BasePoseDetector
            ? 'base'
            : 'accurate',
        "detectorMode":
        poseDetectionMode == PoseDetectionMode.StaticImage ? 2 : 1,
        "selections": selectionType == LandmarkSelectionType.specific
            ? 'specific'
            : 'all',
        "landmarksList": poseLandmarks
      };
}

class PoseLandmark {
  static const int NOSE = 0;
  static const int LEFT_EYE_INNER = 1;
  static const int LEFT_EYE = 2;
  static const int LEFT_EYE_OUTER = 3;
  static const int RIGHT_EYE_INNER = 4;
  static const int RIGHT_EYE = 5;
  static const int RIGHT_EYE_OUTER = 6;
  static const int LEFT_EAR = 7;
  static const int RIGHT_EAR = 8;
  static const int LEFT_MOUTH = 9;
  static const int RIGHT_MOUTH = 10;
  static const int LEFT_SHOULDER = 11;
  static const int RIGHT_SHOULDER = 12;
  static const int LEFT_ELBOW = 13;
  static const int RIGHT_ELBOW = 14;
  static const int LEFT_WRIST = 15;
  static const int RIGHT_WRIST = 16;
  static const int LEFT_PINKY = 17;
  static const int RIGHT_PINKY = 18;
  static const int LEFT_INDEX = 19;
  static const int RIGHT_INDEX = 20;
  static const int LEFT_THUMB = 21;
  static const int RIGHT_THUMB = 22;
  static const int LEFT_HIP = 23;
  static const int RIGHT_HIP = 24;
  static const int LEFT_KNEE = 25;
  static const int RIGHT_KNEE = 26;
  static const int LEFT_ANKLE = 27;
  static const int RIGHT_ANKLE = 28;
  static const int LEFT_HEEL = 29;
  static const int RIGHT_HEEL = 30;
  static const int LEFT_FOOT_INDEX = 31;
  static const int RIGHT_FOOT_INDEX = 32;

  PoseLandmark(this.landmarkLocation, this.x, this.y);


  final int landmarkLocation;
  final double x;
  final double y;

}
