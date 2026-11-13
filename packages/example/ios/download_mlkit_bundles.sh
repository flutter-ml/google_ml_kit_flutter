#!/bin/bash
#
# Downloads the ML Kit resource bundles (models) that the SPM-based build does
# not ship inside the frameworks, and places them in ./mlkit_bundles where the
# Xcode project expects them (see the "MLKit Bundles" group in
# Runner.xcodeproj/project.pbxproj).
#
# The bundles are large model files, so they are not committed; run this script
# once after cloning (and again if the ML Kit version changes):
#
#   cd packages/example/ios
#   ./download_mlkit_bundles.sh [version]     # default: 9.0.3
#
# They come from the d-date/google-mlkit-swiftpm release, the same source the
# frameworks come from.

set -e

VERSION="${1:-9.0.3}"
BASE_URL="https://github.com/d-date/google-mlkit-swiftpm/releases/download/${VERSION}"
DEST_DIR="$(cd "$(dirname "$0")" && pwd)/mlkit_bundles"

echo "Downloading ML Kit ${VERSION} resource bundles into ${DEST_DIR} ..."
mkdir -p "${DEST_DIR}"

BUNDLES=(
  "GoogleMVFaceDetectorResources.bundle"
  "LatinOCRResources.bundle"
  "MLKitImageLabelingResources.bundle"
  "MLKitObjectDetectionResources.bundle"
  "MLKitObjectDetectionCommonResources.bundle"
  "MLKitPoseDetectionFastResources.bundle"
  "MLKitPoseDetectionAccurateResources.bundle"
  "MLKitPoseDetectionCommonResources.bundle"
  "MLKitSegmentationSelfieResources.bundle"
  "MLKitSegmentationCommonResources.bundle"
  "MLKitXenoResources.bundle"
  "MLKitTranslate_resource.bundle"
  "MLKitDigitalInkRecognition_resource.bundle"
  "PredictOnDeviceResource.bundle"
  "PredictOnDevice_resource.bundle"
)

for BUNDLE in "${BUNDLES[@]}"; do
  echo "  ${BUNDLE} ..."
  TMP="$(mktemp -d)"
  if ! curl -fL -o "${TMP}/${BUNDLE}.zip" "${BASE_URL}/${BUNDLE}.zip"; then
    echo "  WARNING: could not download ${BUNDLE} (skipped)"
    rm -rf "${TMP}"
    continue
  fi
  rm -rf "${DEST_DIR}/${BUNDLE}"
  unzip -q -o "${TMP}/${BUNDLE}.zip" -d "${DEST_DIR}"
  rm -rf "${TMP}"
done

echo "Done. ${#BUNDLES[@]} bundles requested."
ls -1 "${DEST_DIR}"
