#!/bin/bash
cd /tmp/release_assets
gh release upload 9.0.0-1 --repo arrrrny/google-mlkit-swiftpm *.zip --clobber
echo "UPLOAD_DONE"
