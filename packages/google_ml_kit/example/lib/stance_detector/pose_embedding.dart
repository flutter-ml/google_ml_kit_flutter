import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import './point_f3d.dart';
import './pose_math.dart';

class PoseEmbedding {
  // Multiplier to apply to the torso to get minimal body size. Picked this by experimentation.
  static const double defaultTorsoMultiplier = 2.5;

  static List<PointF3D> getPoseEmbedding(List<PointF3D> landmarks) {
    final List<PointF3D> normalizedLandmarks = normalize(landmarks);
    return getEmbedding(normalizedLandmarks);
  }

  static List<PointF3D> normalize(List<PointF3D> landmarks) {
    List<PointF3D> normalizedLandmarks = landmarks.toList(); // deepclone?
    // Normalize translation.
    final PointF3D center = PoseMath.average(landmarks.elementAt(PoseLandmarkType.leftHip.index), landmarks.elementAt(PoseLandmarkType.rightHip.index));
    normalizedLandmarks = PoseMath.subtractAll(center, normalizedLandmarks);

    // Normalize scale.
    normalizedLandmarks = PoseMath.multiplyAllX(normalizedLandmarks, 1.0 / getPoseSize(normalizedLandmarks));
    // Multiplication by 100 is not required, but makes it easier to debug.
    normalizedLandmarks = PoseMath.multiplyAllX(normalizedLandmarks, 100);
    return normalizedLandmarks;
  }

  // Translation normalization should've been done prior to calling this method.
  static double getPoseSize(List<PointF3D> landmarks) {
    // Note: This approach uses only 2D landmarks to compute pose size as using Z wasn't helpful
    // in our experimentation but you're welcome to tweak.
    final PointF3D hipsCenter = PoseMath.average(landmarks.elementAt(PoseLandmarkType.leftHip.index), landmarks.elementAt(PoseLandmarkType.rightHip.index));

    final PointF3D shouldersCenter = PoseMath.average(landmarks.elementAt(PoseLandmarkType.leftShoulder.index), landmarks.elementAt(PoseLandmarkType.rightShoulder.index));

    final double torsoSize = PoseMath.l2Norm2D(PoseMath.subtract(hipsCenter, shouldersCenter));

    double maxDistance = torsoSize * defaultTorsoMultiplier;
    // torsoSize * TORSO_MULTIPLIER is the floor we want based on experimentation but actual size
    // can be bigger for a given pose depending on extension of limbs etc so we calculate that.
    for (PointF3D landmark in landmarks) {
      double distance = PoseMath.l2Norm2D(PoseMath.subtract(hipsCenter, landmark));
      if (distance > maxDistance) {
        maxDistance = distance;
      }
    }
    return maxDistance;
  }

  static List<PointF3D> getEmbedding(List<PointF3D> lm) {
    final List<PointF3D> embedding = [];

    //const jointLabels = "hip-shoulder, left-shoulder-elbow, right-shoulder-elbow, left-elbow-wrist, right-elbow-wrist, left-hip-knee, right-hip-knee, left-knee-ankle, right-knee-ankle, left-shoulder-wrist, right-shoulder-wrist, left-hip-ankle, right-hip-ankle, left-hip-wrist, right-hip-wrist, left-shoulder-ankle, right-shoulder-ankle, left-hip-wrist, right-hip-wrist, left-right-elbow, left-right-knee, left-right-wrist, left-right-ankle";
    // We use several pairwise 3D distances to form pose embedding. These were selected
    // based on experimentation for best results with our default pose classes as captued in the
    // pose samples csv. Feel free to play with this and add or remove for your use-cases.
    // We group our distances by number of joints between the pairs.
    // One joint.
    /// hip-shoulder
    embedding.add(PoseMath.subtract(PoseMath.average(lm.elementAt(PoseLandmarkType.leftHip.index), lm.elementAt(PoseLandmarkType.rightHip.index)),
        PoseMath.average(lm.elementAt(PoseLandmarkType.leftShoulder.index), lm.elementAt(PoseLandmarkType.rightShoulder.index))));

    /// left-shoulder-elbow
    /// right-shoulder-elbow
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftShoulder.index), lm.elementAt(PoseLandmarkType.leftElbow.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightShoulder.index), lm.elementAt(PoseLandmarkType.rightElbow.index)));

    /// left-elbow-wrist
    /// right-elbow-wrist
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftElbow.index), lm.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightElbow.index), lm.elementAt(PoseLandmarkType.rightWrist.index)));

    /// left-hip-knee
    /// right-hip-knee
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftHip.index), lm.elementAt(PoseLandmarkType.leftKnee.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightHip.index), lm.elementAt(PoseLandmarkType.rightKnee.index)));

    /// left-knee-ankle
    /// right-knee-ankle
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftKnee.index), lm.elementAt(PoseLandmarkType.leftAnkle.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightKnee.index), lm.elementAt(PoseLandmarkType.rightAnkle.index)));

    // Two joints.
    /// left-shoulder-wrist
    /// right-shoulder-wrist
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftShoulder.index), lm.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightShoulder.index), lm.elementAt(PoseLandmarkType.rightWrist.index)));
    /// left-hip-ankle
    /// right-hip-ankle
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftHip.index), lm.elementAt(PoseLandmarkType.leftAnkle.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightHip.index), lm.elementAt(PoseLandmarkType.rightAnkle.index)));

    // Four joints.
    /// left-hip-wrist
    /// right-hip-wrist
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftHip.index), lm.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightHip.index), lm.elementAt(PoseLandmarkType.rightWrist.index)));

    // Five joints.
    /// left-shoulder-ankle
    /// right-shoulder-ankle
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftShoulder.index), lm.elementAt(PoseLandmarkType.leftAnkle.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightShoulder.index), lm.elementAt(PoseLandmarkType.rightAnkle.index)));
    /// left-hip-wrist
    /// right-hip-wrist
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftHip.index), lm.elementAt(PoseLandmarkType.leftWrist.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.rightHip.index), lm.elementAt(PoseLandmarkType.rightWrist.index)));

    // Cross body.
    /// left-right-elbow
    /// left-right-knee
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftElbow.index), lm.elementAt(PoseLandmarkType.rightElbow.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftKnee.index), lm.elementAt(PoseLandmarkType.rightKnee.index)));
    /// left-right-wrist
    /// left-right-ankle
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftWrist.index), lm.elementAt(PoseLandmarkType.rightWrist.index)));
    embedding.add(PoseMath.subtract(lm.elementAt(PoseLandmarkType.leftAnkle.index), lm.elementAt(PoseLandmarkType.rightAnkle.index)));


    //const jointLabels = "class, hip-shoulder, left-shoulder-elbow, right-shoulder-elbow, left-elbow-wrist, right-elbow-wrist, left-hip-knee, right-hip-knee, left-knee-ankle, right-knee-ankle, left-shoulder-wrist, right-shoulder-wrist, left-hip-ankle, right-hip-ankle, left-hip-wrist, right-hip-wrist, left-shoulder-ankle, right-shoulder-ankle, left-hip-wrist, right-hip-wrist, left-right-elbow, left-right-knee, left-right-wrist, left-right-ankle";
    // List<String> jointLabels =
    // "hip-shoulder, left-shoulder-elbow, right-shoulder-elbow, left-elbow-wrist, right-elbow-wrist, left-hip-knee, right-hip-knee, left-knee-ankle, right-knee-ankle, left-shoulder-wrist, right-shoulder-wrist, left-hip-ankle, right-hip-ankle, left-hip-wrist, right-hip-wrist, left-shoulder-ankle, right-shoulder-ankle, left-hip-wrist, right-hip-wrist, left-right-elbow, left-right-knee, left-right-wrist, left-right-ankle"
    //     .split(",");
    return embedding;
  }
}
