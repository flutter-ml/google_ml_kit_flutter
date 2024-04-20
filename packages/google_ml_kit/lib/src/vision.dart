import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_digital_ink_recognition/google_mlkit_digital_ink_recognition.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:google_mlkit_face_mesh_detection/google_mlkit_face_mesh_detection.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:google_mlkit_object_detection/google_mlkit_object_detection.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import 'package:google_mlkit_selfie_segmentation/google_mlkit_selfie_segmentation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

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
  @Deprecated(
      'Use [google_mlkit_image_labeling] plugin directly instead of [google_ml_kit].')
  ImageLabeler imageLabeler([ImageLabelerOptions? imageLabelerOptions]) {
    return ImageLabeler(options: imageLabelerOptions ?? ImageLabelerOptions());
  }

  /// Returns instance of [BarcodeScanner]. By default it searches the input image for all [BarcodeFormat]s.
  /// To limit the search model to specific [BarcodeFormat] pass list of [BarcodeFormat] as argument.
  @Deprecated(
      'Use [google_mlkit_barcode_scanning] plugin directly instead of [google_ml_kit].')
  BarcodeScanner barcodeScanner([List<BarcodeFormat>? formatList]) {
    return BarcodeScanner(formats: formatList ?? [BarcodeFormat.all]);
  }

  /// Returns instance of [PoseDetector].By default it returns all [PoseLandmark] available in image
  /// To limit the result to specific [PoseLandmark] pass list of [PoseLandmark]'s a
  /// All the 33 positions have been declared as static constants in [PoseLandmark] class
  @Deprecated(
      'Use [google_mlkit_pose_detection] plugin directly instead of [google_ml_kit].')
  PoseDetector poseDetector({PoseDetectorOptions? poseDetectorOptions}) {
    return PoseDetector(options: poseDetectorOptions ?? PoseDetectorOptions());
  }

  /// Returns an instance of [DigitalInkRecognizer]
  @Deprecated(
      'Use [google_mlkit_digital_ink_recognition] plugin directly instead of [google_ml_kit].')
  DigitalInkRecognizer digitalInkRecognizer({required String languageCode}) {
    return DigitalInkRecognizer(languageCode: languageCode);
  }

  /// Return an instance of [TextRecognizer].
  @Deprecated(
      'Use [google_mlkit_text_recognition] plugin directly instead of [google_ml_kit].')
  TextRecognizer textRecognizer({script = TextRecognitionScript.latin}) {
    return TextRecognizer(script: script);
  }

  /// Return an instance of [FaceDetector].
  @Deprecated(
      'Use [google_mlkit_face_detection] plugin directly instead of [google_ml_kit].')
  FaceDetector faceDetector([FaceDetectorOptions? options]) {
    return FaceDetector(options: options ?? FaceDetectorOptions());
  }

  /// Return an instance of [FaceMeshDetector].
  @Deprecated(
      'Use [google_mlkit_face_mesh_detection] plugin directly instead of [google_ml_kit].')
  FaceMeshDetector faceMeshDetector([FaceMeshDetectorOptions? option]) {
    return FaceMeshDetector(option: option ?? FaceMeshDetectorOptions.faceMesh);
  }

  /// Returns an instance of [ObjectDetector].
  @Deprecated(
      'Use [google_mlkit_object_detection] plugin directly instead of [google_ml_kit].')
  ObjectDetector objectDetector({required ObjectDetectorOptions options}) {
    return ObjectDetector(options: options);
  }

  /// Returns an instance of [SelfieSegmenter].
  @Deprecated(
      'Use [google_mlkit_selfie_segmentation] plugin directly instead of [google_ml_kit].')
  SelfieSegmenter selfieSegmenter(
      {SegmenterMode mode = SegmenterMode.stream,
      bool enableRawSizeMask = false}) {
    return SelfieSegmenter(mode: mode, enableRawSizeMask: enableRawSizeMask);
  }
}
