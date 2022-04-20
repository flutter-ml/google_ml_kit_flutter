import 'package:google_mlkit_barcode_scanning/barcode_scanner.dart';
import 'package:google_mlkit_digital_ink_recognition/digital_ink_recognizer.dart';
import 'package:google_mlkit_face_detection/face_detector.dart';
import 'package:google_mlkit_image_labeling/image_labeler.dart';
import 'package:google_mlkit_object_detection/object_detector.dart';
import 'package:google_mlkit_pose_detection/pose_detector.dart';
import 'package:google_mlkit_text_recognition/text_recognizer.dart';

/// Get instance of the individual api's using instance of [Vision]
/// For example
/// To get an instance of [ImageLabeler]
/// ImageLabeler imageLabeler = GoogleMlKit.instance.imageLabeler();
class Vision {
  Vision._();

  // Creates an instance of [GoogleMlKit] by calling the private constructor
  static final Vision instance = Vision._();

  /// Get an instance of [ImageLabeler] by calling this function
  /// [imageLabelerOptions]  if not provided it creates [ImageLabeler] with [ImageLabelerOptions]
  /// You can provide either [LocalLabelerOptions] to use a custom tflite model
  /// Or [AutoMLImageLabelerOptions] to use auto ml vision model trained by you
  ImageLabeler imageLabeler([ImageLabelerOptionsBase? imageLabelerOptions]) {
    return ImageLabeler(options: imageLabelerOptions ?? ImageLabelerOptions());
  }

  /// Returns instance of [BarcodeScanner]. By default it searches the input image for all [BarcodeFormat]s.
  /// To limit the search model to specific [BarcodeFormat] pass list of [BarcodeFormat] as argument.
  BarcodeScanner barcodeScanner([List<BarcodeFormat>? formatList]) {
    return BarcodeScanner(formats: formatList ?? [BarcodeFormat.all]);
  }

  /// Returns instance of [PoseDetector].By default it returns all [PoseLandmark] available in image
  /// To limit the result to specific [PoseLandmark] pass list of [PoseLandmark]'s a
  /// All the 33 positions have been declared as static constants in [PoseLandmark] class
  PoseDetector poseDetector({PoseDetectorOptions? poseDetectorOptions}) {
    return PoseDetector(options: poseDetectorOptions ?? PoseDetectorOptions());
  }

  /// Returns an instance of [DigitalInkRecognizer]
  DigitalInkRecognizer digitalInkRecognizer() {
    return DigitalInkRecognizer();
  }

  /// Return an instance of [TextRecognizer].
  TextRecognizer textRecognizer({script = TextRecognitionScript.latin}) {
    return TextRecognizer(script: script);
  }

  /// Return an instance of [FaceDetector].
  FaceDetector faceDetector([FaceDetectorOptions? options]) {
    return FaceDetector(options: options ?? const FaceDetectorOptions());
  }

  /// Returns an instance of [ObjectDetector].
  ObjectDetector objectDetector(
      [ObjectDetectorOptions options = const ObjectDetectorOptions()]) {
    return ObjectDetector(options: options);
  }
}
