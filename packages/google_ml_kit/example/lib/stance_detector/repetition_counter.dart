/*
 * Copyright 2020 Google LLC. All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

// package com.google.mlkit.vision.demo.java.posedetector.classification;

import 'classification_result.dart';

/// Counts reps for the give class.
class RepetitionCounter {
  // These thresholds can be tuned in conjunction with the Top K values in {@link PoseClassifier}.
  // The default Top K value is 10 so the range here is [0-10].
  static const double defaultEnterThreshold = 6;
  static const double defaultExitThreshold = 4;

  late final String className;
  late final double enterThreshold;
  late final double exitThreshold;
  late final Function(String className, int count)? onCountInc;
  int numRepeats = 0;

  bool poseEntered = false;

  RepetitionCounter({required this.className, this.enterThreshold = defaultEnterThreshold, this.exitThreshold = defaultExitThreshold, this.onCountInc});

  //  RepetitionCounter(String className) {
  //   this(className, DEFAULT_ENTER_THRESHOLD, DEFAULT_EXIT_THRESHOLD);
  // }
  //
  //  RepetitionCounter(String className, double enterThreshold, double exitThreshold) {
  //   this.className = className;
  //   this.enterThreshold = enterThreshold;
  //   this.exitThreshold = exitThreshold;
  //   numRepeats = 0;
  //   poseEntered = false;
  // }

  /// Adds a new Pose classification result and updates reps for given class.
  ///
  /// @param classificationResult {link ClassificationResult} of class to confidence values.
  /// @return number of reps.
  int addClassificationResult(ClassificationResult classificationResult) {
    final double poseConfidence = classificationResult.getClassConfidence(className);
    //print('$className : $poseConfidence  - poseEntered: $poseEntered');
    if (!poseEntered) {
      poseEntered = poseConfidence > enterThreshold;
      return numRepeats;
    }

    if (poseConfidence < exitThreshold) {
      numRepeats++;
      poseEntered = false;
      onCountInc!(className, numRepeats);
    }

    return numRepeats;
  }

  String getClassName() {
    return className;
  }

  int getNumRepeats() {
    return numRepeats;
  }
}
