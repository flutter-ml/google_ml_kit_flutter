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
//
// import android.os.SystemClock;
// import java.util.Deque;
// import java.util.HashSet;
// import java.util.Set;
// import java.util.concurrent.LinkedBlockingDeque;

import 'dart:collection';

import 'classification_result.dart';

/// Runs EMA smoothing over a window with given stream of pose classification results.
class EMASmoothing {
  static const int defaultWindowSize = 10;
  static const double defaultAlpha = 0.2;

  static const double resetThresholdMS = 200;

  final int windowSize;
  final double alpha;

  // This is a window of {@link ClassificationResult}s as outputted by the {@link PoseClassifier}.
  // We run smoothing over this window of size {@link windowSize}.
  late final Queue<ClassificationResult> window;

  int lastInputMs = -1;

  EMASmoothing({this.windowSize = defaultWindowSize, this.alpha = defaultAlpha}) {
    window = Queue();
  }

  //  EMASmoothing() {
  //   this(DEFAULT_WINDOW_SIZE, DEFAULT_ALPHA);
  // }
  //
  //  EMASmoothing(int windowSize, double alpha) {
  //   this.windowSize = windowSize;
  //   this.alpha = alpha;
  //   this.window = new LinkedBlockingDeque<>(windowSize);
  // }

  ClassificationResult getSmoothedResult(ClassificationResult classificationResult) {
    // Resets memory if the input is too far away from the previous one in time.
    // double nowMs = SystemClock.elapsedRealtime();
    final int nowMs = DateTime.now().millisecondsSinceEpoch;
    if (nowMs - lastInputMs > resetThresholdMS) {
      window.clear();
    }
    lastInputMs = nowMs;

    // If we are at window size, remove the last (oldest) result.
    if (window.length == windowSize) {
      // window.pollLast();
      window.removeLast();
    }
    // Insert at the beginning of the window.
    window.addFirst(classificationResult);

    final Set<String> allClasses = HashSet();
    for (final ClassificationResult result in window) {
      allClasses.addAll(result.getAllClasses());
    }

    final ClassificationResult smoothedResult = ClassificationResult();

    for (final String className in allClasses) {
      double factor = 1;
      double topSum = 0;
      double bottomSum = 0;
      for (final ClassificationResult result in window) {
        final double value = result.getClassConfidence(className);

        topSum += factor * value;
        bottomSum += factor;

        factor = (factor * (1.0 - alpha));
      }
      smoothedResult.putClassConfidence(className, topSum / bottomSum);
    }

    return smoothedResult;
  }
}
