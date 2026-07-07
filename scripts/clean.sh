#!/bin/sh

cd "$(dirname "$0")/.."
cd packages

cd google_mlkit_commons
flutter clean

cd ../google_mlkit_barcode_scanning
flutter clean

cd ../google_mlkit_digital_ink_recognition
flutter clean

cd ../google_mlkit_document_scanner
flutter clean

cd ../google_mlkit_entity_extraction
flutter clean

cd ../google_mlkit_face_detection
flutter clean

cd ../google_mlkit_face_mesh_detection
flutter clean

cd ../google_mlkit_image_labeling
flutter clean

cd ../google_mlkit_language_id
flutter clean

cd ../google_mlkit_object_detection
flutter clean

cd ../google_mlkit_pose_detection
flutter clean

cd ../google_mlkit_selfie_segmentation
flutter clean

cd ../google_mlkit_subject_segmentation
flutter clean

cd ../google_mlkit_smart_reply
flutter clean

cd ../google_mlkit_text_recognition
flutter clean

cd ../google_mlkit_translation
flutter clean

cd ../google_mlkit_genai_summarization
flutter clean

cd ../google_mlkit_genai_proofreading
flutter clean

cd ../google_mlkit_genai_rewriting
flutter clean

cd ../google_mlkit_genai_image_description
flutter clean

cd ../google_mlkit_genai_speech_recognition
flutter clean

cd ../google_mlkit_genai_prompt
flutter clean

cd ../google_ml_kit
flutter clean

cd ../example
flutter clean
