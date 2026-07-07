#!/bin/bash
cd /Users/ahmettok/Developer/zikzak_ml_kit_flutter
SRC="packages/google_mlkit_text_recognition/ios/google_mlkit_text_recognition/Sources/google_mlkit_text_recognition"
DST="/tmp/release_assets"
for lang in Latin Chinese Devanagari Japanese Korean; do
  zip -r -X "$DST/${lang}OCRResources.bundle.zip" "$SRC/${lang}OCRResources.bundle/"
done
ls -lh "$DST"/*.bundle.zip
echo "ALL_BUNDLES_DONE"
