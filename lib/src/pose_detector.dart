part of 'google_ml_kit.dart';

//enum to specify whether to use base pose model or accurate posed model
//To know differences between these two visit this [https://developers.google.com/ml-kit/vision/pose-detection/android] site
enum PoseDetectionModel { BasePoseDetector, AccuratePoseDetector }

//To decide whether you want to process a static image and wait for a future
//or stream image please note feature to stream image is not yet available and will be implemented in the future
enum PoseDetectionMode { StaticImage, StreamImage }
enum LandmarkSelectionType { all, specific }

///A detector that processes the input image and return list of [PoseLandmark]
///To gt an instance of the class
/// create [PoseDetectorOptions]
///  final options = PoseDetectorOptions(
///    poseDetectionModel: PoseDetectionModel.AccuratePoseDetector,
///     poseDetectionMode: PoseDetectionMode.StaticImage);
///     Note : [PoseDetectorOptions] is optional parameter,if not given it gives [PoseDetector] with default options
///   PoseDetector poseDetector = GoogleMlKit.instance.poseDetector();
class PoseDetector {
  final PoseDetectorOptions poseDetectorOptions;
  bool _isOpened = false;
  bool _isClosed = false;

  PoseDetector(this.poseDetectorOptions);

  Future<Map<int, PoseLandmark>> processImage(InputImage inputImage) async {
    assert(inputImage != null);
    _isOpened = true;

    List<dynamic> result = await GoogleMlKit.channel
        .invokeMethod('startPoseDetector', <String, dynamic>{
      'options': poseDetectorOptions._detectorOption(),
      'imageData': inputImage._getImageData()
    });

    List<PoseLandmark> poseLandmarks = <PoseLandmark>[];
    if (result != null) {
      poseLandmarks.addAll(result
          .map((item) => PoseLandmark(item['type'], item['x'], item['y'])));
    }

    Map<int, PoseLandmark> map = Map.fromIterable(result,
        key: (item) => item['position'],
        value: (item) => PoseLandmark(item['type'], item['x'], item['y']));

    return map;
  }

  Future<void> close() async {
    if (!_isClosed && _isOpened) {
      await GoogleMlKit.channel.invokeMethod('closePoseDetector');
      _isClosed = true;
      _isOpened = false;
    }
  }
}

///[PoseDetectorOptions] determines the parameters on which [PoseDetector] works

class PoseDetectorOptions {

  //enum PoseDetectionModel default is set to Base Pose Detector Model
  final PoseDetectionModel poseDetectionModel;

  //enum PoseDetectionMode, currently only static supported
  final PoseDetectionMode poseDetectionMode;

  //List of poseLandmarks you want to obtain from the image
  //By default it returns all available available [PoseLandmarks]
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
        'detectorType':
        poseDetectionModel == PoseDetectionModel.BasePoseDetector
            ? 'base'
            : 'accurate',
        'detectorMode':
        poseDetectionMode == PoseDetectionMode.StaticImage ? 2 : 1,
        'selections': selectionType == LandmarkSelectionType.specific
            ? 'specific'
            : 'all',
        'landmarksList': poseLandmarks
      };
}

///This gives the [Offset] information as to where pose landmarks are locates in image
class PoseLandmark {

  //An integer notation to identify NOSE part of body
  static const int NOSE = 0;

  //An integer notation to identify LEFT_EYE_INNER part of body
  static const int LEFT_EYE_INNER = 1;

  //An integer notation to identify LEFT_EYE part of body
  static const int LEFT_EYE = 2;

  //An integer notation to identify LEFT_EYE_OUTER part of body
  static const int LEFT_EYE_OUTER = 3;

  //An integer notation to identify RIGHT_EYE_INNER part of body
  static const int RIGHT_EYE_INNER = 4;

  //An integer notation to identify RIGHT_EYE part of body
  static const int RIGHT_EYE = 5;

  //An integer notation to identify RIGHT_EYE_OUTER part of body
  static const int RIGHT_EYE_OUTER = 6;

  //An integer notation to identify LEFT_EAR part of body
  static const int LEFT_EAR = 7;

  //An integer notation to identify RIGHT_EAR part of body
  static const int RIGHT_EAR = 8;

  //An integer notation to identify LEFT_MOUTH part of body
  static const int LEFT_MOUTH = 9;

  //An integer notation to identify RIGHT_MOUTH part of body
  static const int RIGHT_MOUTH = 10;

  //An integer notation to identify LEFT_SHOULDER part of body
  static const int LEFT_SHOULDER = 11;

  //An integer notation to identify RIGHT_SHOULDER part of body
  static const int RIGHT_SHOULDER = 12;

  //An integer notation to identify LEFT_ELBOW part of body
  static const int LEFT_ELBOW = 13;

  //An integer notation to identify RIGHT_ELBOW part of body
  static const int RIGHT_ELBOW = 14;

  //An integer notation to identify LEFT_WRIST part of body
  static const int LEFT_WRIST = 15;

  //An integer notation to identify RIGHT_WRIST part of body
  static const int RIGHT_WRIST = 16;

  //An integer notation to identify LEFT_PINKY part of body
  static const int LEFT_PINKY = 17;

  //An integer notation to identify RIGHT_PINKY part of body
  static const int RIGHT_PINKY = 18;

  //An integer notation to identify LEFT_INDEX part of body
  static const int LEFT_INDEX = 19;

  //An integer notation to identify RIGHT_INDEX part of body
  static const int RIGHT_INDEX = 20;

  //An integer notation to identify LEFT_THUMB part of body
  static const int LEFT_THUMB = 21;

  //An integer notation to identify RIGHT_THUMB part of body
  static const int RIGHT_THUMB = 22;

  //An integer notation to identify LEFT_HIP part of body
  static const int LEFT_HIP = 23;

  //An integer notation to identify RIGHT_HIP part of body
  static const int RIGHT_HIP = 24;

  //An integer notation to identify LEFT_KNEE part of body
  static const int LEFT_KNEE = 25;

  //An integer notation to identify RIGHT_KNEE part of body
  static const int RIGHT_KNEE = 26;

  //An integer notation to identify LEFT_ANKLE part of body
  static const int LEFT_ANKLE = 27;

  //An integer notation to identify RIGHT_ANKLE part of body
  static const int RIGHT_ANKLE = 28;

  //An integer notation to identify LEFT_HEEL part of body
  static const int LEFT_HEEL = 29;

  //An integer notation to identify RIGHT_HEEL part of body
  static const int RIGHT_HEEL = 30;

  //An integer notation to identify LEFT_FOOT_INDEX part of body
  static const int LEFT_FOOT_INDEX = 31;

  //An integer notation to identify RIGHT_FOOT_INDEX part of body
  static const int RIGHT_FOOT_INDEX = 32;

  PoseLandmark(this.landmarkLocation, this.x, this.y);

  final int landmarkLocation;

  //Gives x position of landmark in image
  final double x;

  //Gives y position of landmark in image
  final double y;
}
