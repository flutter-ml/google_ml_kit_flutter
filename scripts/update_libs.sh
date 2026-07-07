#!/bin/sh

# Don't exit on error for GenAI packages as they may be incomplete
# set -e

cd "$(dirname "$0")/.."
cd packages

cd google_mlkit_commons
flutter pub get

cd ../google_mlkit_barcode_scanning
flutter pub get

cd ../google_mlkit_digital_ink_recognition
flutter pub get

cd ../google_mlkit_document_scanner
flutter pub get

cd ../google_mlkit_entity_extraction
flutter pub get

cd ../google_mlkit_face_detection
flutter pub get

cd ../google_mlkit_face_mesh_detection
flutter pub get

cd ../google_mlkit_image_labeling
flutter pub get

cd ../google_mlkit_language_id
flutter pub get

cd ../google_mlkit_object_detection
flutter pub get

cd ../google_mlkit_pose_detection
flutter pub get

cd ../google_mlkit_selfie_segmentation
flutter pub get

cd ../google_mlkit_subject_segmentation
flutter pub get

cd ../google_mlkit_smart_reply
flutter pub get

cd ../google_mlkit_text_recognition
flutter pub get

cd ../google_mlkit_translation
flutter pub get

cd ../google_mlkit_genai_summarization
flutter pub get

cd ../google_mlkit_genai_proofreading
flutter pub get

cd ../google_mlkit_genai_rewriting
flutter pub get

cd ../google_mlkit_genai_image_description
flutter pub get

cd ../google_mlkit_genai_speech_recognition
flutter pub get

cd ../google_mlkit_genai_prompt
flutter pub get

cd ../google_ml_kit
flutter pub get

cd ../example
flutter pub get
