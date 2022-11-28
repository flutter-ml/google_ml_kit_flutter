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
// import android.content.Context;
// import android.media.AudioManager;
// import android.media.ToneGenerator;
// import android.os.Looper;
// import android.util.Log;
// import androidx.annotation.WorkerThread;
// import com.google.common.base.Preconditions;
// import com.google.mlkit.vision.pose.Pose;
// import java.io.BufferedReader;
// import java.io.IOException;
// import java.io.InputStreamReader;
// import java.util.ArrayList;
// import java.util.List;
// import java.util.Locale;

import 'dart:convert';
import 'dart:core';

import 'package:flutter/services.dart';
import 'package:google_mlkit_pose_detection/google_mlkit_pose_detection.dart';
import './pose_classifier.dart';
import './pose_sample.dart';
import './repetition_counter.dart';

import 'classification_result.dart';
import 'ema_smoothing.dart';

/// Accepts a stream of {@link Pose} for classification and Rep counting.
class PoseClassifierProcessor {
  static const String defaultPoseSamplesFile = 'assets/ml/fitness_pose_samples.csv';
 // static const String defaultPoseSamplesFile = "assets/ml/fitness_pose_squats.csv";

  // Specify classes for which we want rep counting.
  // These are the labels in the given {@code POSE_SAMPLES_FILE}. You can set your own class labels
  // for your pose samples.
  static const String defaultPushUpsClass = 'pushups_down';
  static const String defaultSquatsClass = 'squats_down';
  static final List<String> defaultPoseClasses = [defaultSquatsClass];//defaultPushUpsClass, defaultSquatsClass

  final bool isStreamMode;
  late EMASmoothing emaSmoothing;
  late List<RepetitionCounter> repCounters;
  late PoseClassifier poseClassifier;
  late String lastRepResult;

  late final Function(String className, int count)? onRepInc;

  // @WorkerThread
  PoseClassifierProcessor({required this.isStreamMode, required this.onRepInc}) {
    // Preconditions.checkState(Looper.myLooper() != Looper.getMainLooper());
    // this.isStreamMode = isStreamMode;
    if (isStreamMode) {
      emaSmoothing = EMASmoothing();
      repCounters = [];
      lastRepResult = '';
    }
    loadPoseSamples();
  }

  void loadPoseSamples({String poseSamplesFile = defaultPoseSamplesFile}) async {
    final List<PoseSample> poseSamples = [];

    final String csvFile = await rootBundle.loadString(poseSamplesFile);
    final LineSplitter splitter = const LineSplitter();
    final List<String> lines = splitter.convert(csvFile);
    //
    for (final csvLine in lines) {
      final PoseSample? poseSample = PoseSample.getPoseSample(csvLine, ',');
      if (poseSample != null) {
        poseSamples.add(poseSample);
      }
    }
    poseClassifier = PoseClassifier(poseSamples: poseSamples);
    if (isStreamMode) {
      for (final className in defaultPoseClasses) {
        repCounters.add(RepetitionCounter(className: className, onCountInc:onRepInc));
      }
    }
  }

  RepetitionCounter? getClassCounter(String className)
  {
    try {
      return repCounters.firstWhere((counter) => counter.className == className);
    }catch (e)
    {
      return null;
    }
  }

  /// Given a new {@link Pose} input, returns a list of formatted {@link String}s with Pose
  /// classification results.
  ///
  /// <p>Currently it returns up to 2 strings as following:
  /// 0: PoseClass : X reps
  /// 1: PoseClass : [0.0-1.0] confidence
  // @WorkerThread
  List<String> getPoseResult(Pose pose) {
    // Preconditions.checkState(Looper.myLooper() != Looper.getMainLooper());
    final List<String> result = [];
    ClassificationResult classification = poseClassifier.classifyPose(pose);
    // var cl = classification.getMaxConfidenceClass();
    // print(' c: ${cl} - ${classification.getClassConfidence(cl)}');
    // Update {@link RepetitionCounter}s if {@code isStreamMode}.
    if (isStreamMode) {
      // Feed pose to smoothing even if no pose found.
      classification = emaSmoothing.getSmoothedResult(classification);

      final cl = classification.getMaxConfidenceClass();
      // print(' c: ${cl} - ${classification.getClassConfidence(cl)}');

      // Return early without updating repCounter if no pose found.
      // if (pose.getAllPoseLandmarks().isEmpty()) {
      if (poseClassifier.currentLandmarks.isEmpty) {
        result.add(lastRepResult);
        return result;
      }

      for (final RepetitionCounter repCounter in repCounters) {
        final int repsBefore = repCounter.getNumRepeats();
        final int repsAfter = repCounter.addClassificationResult(classification);
        if (repsAfter > repsBefore) {
          // Play a fun beep when rep counter updates.
          // ToneGenerator tg = new ToneGenerator(AudioManager.STREAM_NOTIFICATION, 100);
          // tg.startTone(ToneGenerator.TONE_PROP_BEEP);
          // lastRepResult = String.format(
          //     Locale.US, "%s : %d reps", repCounter.getClassName(), repsAfter);
          lastRepResult = '${repCounter.getClassName()} : $repsAfter reps';
          // print(lastRepResult);
          break;
        }
      }
      result.add(lastRepResult);
    }
    // var allPoseLandmarks = pose.landmarks.values.toList();

    // Add maxConfidence class of current frame to result if pose is found.
    // if (!pose.getAllPoseLandmarks().isEmpty()) {
    if (poseClassifier.currentLandmarks.isNotEmpty) {
      final String maxConfidenceClass = classification.getMaxConfidenceClass();
      final String maxConfidenceClassResult = '$maxConfidenceClass : ${classification.getClassConfidence(maxConfidenceClass) / poseClassifier.confidenceRange()}';
      // String maxConfidenceClassResult = String.format(
      //     Locale.US,
      //     "%s : %.2f confidence",
      //     maxConfidenceClass,
      //     classification.getClassConfidence(maxConfidenceClass)
      //         / poseClassifier.confidenceRange());
      result.add(maxConfidenceClassResult);
      //print(maxConfidenceClassResult);
    }

    return result;
  }
}
