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
// import android.util.Log;
// import com.google.common.base.Splitter;
// import com.google.mlkit.vision.common.PointF3D;
// import java.util.ArrayList;
// import java.util.List;

import 'dart:core';

import './point_f3d.dart';
import './pose_embedding.dart';


/// Reads Pose samples from a csv file.
class PoseSample {
  static const int defaultNumLandmarks = 33;
  static const int defaultNumDims = 3;

  final String name;
  final String className;
  late final List<PointF3D> embedding;

  PoseSample({required this.name, required this.className, required List<PointF3D> landmarks}) {
    // this.name = name;
    // this.className = className;
    embedding = PoseEmbedding.getPoseEmbedding(landmarks);
  }

  String getName() {
    return name;
  }

  String getClassName() {
    return className;
  }

  List<PointF3D> getEmbedding() {
    return embedding;
  }

  static PoseSample? getPoseSample(String csvLine, String separator) {
    // List<String> tokens = Splitter.onPattern(separator).splitToList(csvLine);
    final List<String> tokens = csvLine.split(',');
    // Format is expected to be Name,Class,X1,Y1,Z1,X2,Y2,Z2...
    // + 2 is for Name & Class.
    if (tokens.length != (defaultNumLandmarks * defaultNumDims) + 2) {
      // Log.e(TAG, "Invalid number of tokens for PoseSample");
      return null;
    }
    final String name = tokens.elementAt(0);
    final String className = tokens.elementAt(1);
    final List<PointF3D> landmarks = [];
    // Read from the third token, first 2 tokens are name and class.
    for (int i = 2; i < tokens.length; i += defaultNumDims) {
      try {
        landmarks.add(PointF3D.from(double.parse(tokens.elementAt(i)), double.parse(tokens.elementAt(i + 1)), double.parse(tokens.elementAt(i + 2))));
      } catch (e) {
        // Log.e(TAG, "Invalid value " + tokens.get(i) + " for landmark position.");
        return null;
      }
    }
    return PoseSample(name: name, className: className, landmarks: landmarks);
  }
}
