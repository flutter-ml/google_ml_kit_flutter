#!/bin/bash
DIR="/tmp/release_assets"
BASE="https://github.com/d-date/google-mlkit-swiftpm/releases/download/9.0.0-1"
for name in MLKitBarcodeScanning MLKitCommon MLKitFaceDetection MLKitVision MLKitTextRecognition MLKitTextRecognitionChinese MLKitTextRecognitionDevanagari MLKitTextRecognitionJapanese MLKitTextRecognitionKorean MLKitImageLabeling MLKitImageLabelingCustom MLKitImageLabelingCommon MLKitObjectDetection MLKitObjectDetectionCustom MLKitObjectDetectionCommon MLKitPoseDetection MLKitPoseDetectionAccurate MLKitPoseDetectionCommon MLKitSegmentationSelfie MLKitSegmentationCommon MLKitLanguageID MLKitTranslate MLKitSmartReply MLKitVisionKit MLKitXenoCommon MLKitNaturalLanguage SSZipArchive; do curl -sL -o "$DIR/$name.xcframework.zip" "$BASE/$name.xcframework.zip"; done
curl -sL -o "$DIR/GoogleMVFaceDetectorResources.bundle.zip" "$BASE/GoogleMVFaceDetectorResources.bundle.zip"
curl -sL -o "$DIR/MLKitTextRecognitionCommon.xcframework.zip" "https://github.com/alex-pan-invos/google-mlkit-swiftpm/releases/download/9.0.0-textfix5/MLKitTextRecognitionCommon.xcframework.zip"
echo "ALL_DONE"
