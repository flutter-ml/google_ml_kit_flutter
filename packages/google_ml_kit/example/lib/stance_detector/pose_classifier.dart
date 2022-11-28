// import static com.google.mlkit.vision.demo.java.posedetector.classification.PoseEmbedding.getPoseEmbedding;
// import static com.google.mlkit.vision.demo.java.posedetector.classification.Utils.maxAbs;
// import static com.google.mlkit.vision.demo.java.posedetector.classification.Utils.multiply;
// import static com.google.mlkit.vision.demo.java.posedetector.classification.Utils.multiplyAll;
// import static com.google.mlkit.vision.demo.java.posedetector.classification.Utils.subtract;
// import static com.google.mlkit.vision.demo.java.posedetector.classification.Utils.sumAbs;
// import static java.lang.Math.max;
// import static java.lang.Math.min;
//
// import android.util.Pair;
// import com.google.mlkit.vision.common.PointF3D;
// import com.google.mlkit.vision.pose.Pose;
// import com.google.mlkit.vision.pose.PoseLandmark;
// import java.util.ArrayList;
// import java.util.List;
// import java.util.PriorityQueue;

import 'dart:core';
import 'dart:math';
import 'package:collection/collection.dart';

import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import './point_f3d.dart';
import './pose_embedding.dart';
import './pose_math.dart';
import './pose_sample.dart';

import 'classification_result.dart';

class Pair<T1, T2> {
  final T1 first;
  final T2 second;

  Pair(this.first, this.second);

  @override
  bool operator ==(Object other) {
    if (other is! Pair) return false;
    return first == other.first && second == other.second;
  }

  @override
  int get hashCode => Object.hash(first.hashCode, second.hashCode);
}

/// Classifies {link Pose} based on given {@link PoseSample}s.
///
/// <p>Inspired by K-Nearest Neighbors Algorithm with outlier filtering.
/// https://en.wikipedia.org/wiki/K-nearest_neighbors_algorithm
class PoseClassifier {
  static const int defaultMaxDistanceTopK = 30;
  static const int defaultMeanDistanceTopK = 10;

  // Note Z has a lower weight as it is generally less accurate than X & Y.
  static final PointF3D defaultAxesWeights = PointF3D.from(1.0, 1.0, 0.2);

  // Referenced externally to avoid repetition.
  List<PointF3D> currentLandmarks = [];

  final List<PoseSample> poseSamples;
  late final int maxDistanceTopK;
  final int meanDistanceTopK;
  late final PointF3D axesWeights;

  PoseClassifier({required this.poseSamples, this.maxDistanceTopK = defaultMaxDistanceTopK, this.meanDistanceTopK = defaultMeanDistanceTopK, axesWeights}) {
    this.axesWeights = axesWeights ?? PointF3D.from(1.0, 1.0, 0.2);
  }

  // PoseClassifier(List<PoseSample> poseSamples) {
  //   (poseSamples, MAX_DISTANCE_TOP_K, MEAN_DISTANCE_TOP_K, AXES_WEIGHTS);
  // }
  //
  // public PoseClassifier(List<PoseSample> poseSamples, int maxDistanceTopK,
  //     int meanDistanceTopK, PointF3D axesWeights) {
  //   this.poseSamples = poseSamples;
  //   this.maxDistanceTopK = maxDistanceTopK;
  //   this.meanDistanceTopK = meanDistanceTopK;
  //   this.axesWeights = axesWeights;
  // }

  static List<PointF3D> extractPoseLandmarks(Pose pose) {
    final List<PointF3D> landmarks = [];
    final List<PoseLandmark> landValues = pose.landmarks.values.toList();
    landValues.sort((a, b) {
      return a.type.index.compareTo(b.type.index);
    });

    for (final PoseLandmark poseLandmark in landValues) // pose.getAllPoseLandmarks()
    {
      landmarks.add(PointF3D(poseLandmark.x, poseLandmark.y, poseLandmark.z)); // poseLandmark.getPosition3D()
    }

    return landmarks;
  }

  /// Returns the max range of confidence values.
  ///
  /// <p><Since we calculate confidence by counting {@link PoseSample}s that survived
  /// outlier-filtering by maxDistanceTopK and meanDistanceTopK, this range is the minimum of two.
  int confidenceRange() {
    return min(maxDistanceTopK, meanDistanceTopK);
  }

  ClassificationResult classifyPose(Pose pose) {
    // return classify(extractPoseLandmarks(pose));
    return classifyLandmarks(PoseClassifier.extractPoseLandmarks(pose));
  }

  ClassificationResult classifyLandmarks(List<PointF3D> landmarks) {
    currentLandmarks = landmarks;
    final ClassificationResult result = ClassificationResult();
    // Return early if no landmarks detected.
    if (landmarks.isEmpty) {
      return result;
    }

    // We do flipping on X-axis so we are horizontal (mirror) invariant.
    List<PointF3D> flippedLandmarks = landmarks; // depp copY?
    flippedLandmarks = PoseMath.multiplyAll(landmarks, PointF3D.from(-1, 1, 1));

    final List<PointF3D> embedding = PoseEmbedding.getPoseEmbedding(landmarks);
    final List<PointF3D> flippedEmbedding = PoseEmbedding.getPoseEmbedding(flippedLandmarks);

    // Classification is done in two stages:
    //  * First we pick top-K samples by MAX distance. It allows to remove samples that are almost
    //    the same as given pose, but maybe has few joints bent in the other direction.
    //  * Then we pick top-K samples by MEAN distance. After outliers are removed, we pick samples
    //    that are closest by average.

    // Keeps max distance on top so we can pop it when top_k size is reached.
    // PriorityQueue<Pair<PoseSample, double>> maxDistances = PriorityQueue((o1, o2) => -double.compare(o1.second, o2.second));
    final PriorityQueue<Pair<PoseSample, double>> maxDistances = PriorityQueue((o1, o2) {
      return -o1.second.compareTo(o2.second);
    });
    // Retrieve top K poseSamples by least distance to remove outliers.
    final List<Pair<PoseSample, List<Pair<int, double>>>> allDistances = [];

    /// We loop through all our samples, looking for the samples that match our input the best.
    /// we then loop through all the points in the sample
    /// - we find the distances between the sample and input position. Smaller distances make for a closer match.
    /// - we multiple the distances on the xyz by the weights, to give more relevance to xy and not x.
    /// - we do this for the original and flipped coordinates.
    /// - of all the embeddings, we keep the largest distance of any embedding
    /// - we same the poseSample with a priority based on the distance.
    ///  - the priority queue comparator keeps large distances at the bottom of the priority queue.
    /// - we remove the entries with the largest distances.
    for (final PoseSample poseSample in poseSamples) {
      final List<PointF3D> sampleEmbedding = poseSample.getEmbedding();

      double originalMax = 0.0;
      double flippedMax = 0.0;
      final List<Pair<int, double>> measured = [];
      for (int i = 0; i < embedding.length; i++) {
        originalMax = max(originalMax, PoseMath.maxAbs(PoseMath.multiply(PoseMath.subtract(embedding.elementAt(i), sampleEmbedding.elementAt(i)), axesWeights)));
        flippedMax = max(flippedMax, PoseMath.maxAbs(PoseMath.multiply(PoseMath.subtract(flippedEmbedding.elementAt(i), sampleEmbedding.elementAt(i)), axesWeights)));
        measured.add(Pair(i, min(originalMax, flippedMax)));
      }
      // Set the max distance as min of original and flipped max distance.
      maxDistances.add(Pair(poseSample, min(originalMax, flippedMax)));

      allDistances.add(Pair(poseSample, measured));
      // We only want to retain top n so pop the highest distance.
      if (maxDistances.length > maxDistanceTopK) {
        // maxDistances.poll();
        maxDistances.removeFirst();
      }
    }

    // Keeps higher mean distances on top so we can pop it when top_k size is reached.
    // PriorityQueue<Pair<PoseSample, double>> meanDistances = PriorityQueue((o1, o2) => -double.compare(o1.second, o2.second));
    final PriorityQueue<Pair<PoseSample, double>> meanDistances = PriorityQueue((o1, o2) => -o1.second.compareTo(o2.second));
    // Retrieve top K poseSamples by least mean distance to remove outliers.
    for (final Pair<PoseSample, double> sampleDistances in maxDistances.toList()) {
      final PoseSample poseSample = sampleDistances.first;
      final List<PointF3D> sampleEmbedding = poseSample.getEmbedding();

      double originalSum = 0.0;
      double flippedSum = 0.0;
      for (int i = 0; i < embedding.length; i++) {
        originalSum += PoseMath.sumAbs(PoseMath.multiply(PoseMath.subtract(embedding.elementAt(i), sampleEmbedding.elementAt(i)), axesWeights));
        flippedSum += PoseMath.sumAbs(PoseMath.multiply(PoseMath.subtract(flippedEmbedding.elementAt(i), sampleEmbedding.elementAt(i)), axesWeights));
      }
      // Set the mean distance as min of original and flipped mean distances.
      final double meanDistance = min(originalSum, flippedSum) / (embedding.length * 2.0);
      meanDistances.add(Pair(poseSample, meanDistance));

      // We only want to retain top k so pop the highest mean distance.
      if (meanDistances.length > meanDistanceTopK) {
        meanDistances.removeFirst();
      }
    }

    for (Pair<PoseSample, double> sampleDistances in meanDistances.toList()) {
      String className = sampleDistances.first.getClassName();
      result.incrementClassConfidence(className);
    }

    return result;
  }
}
