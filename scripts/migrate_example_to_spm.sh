#!/usr/bin/env bash
set -euo pipefail

# Script to prepare the example iOS project for SPM migration.
# Safe operations only: backup workspace, remove Pod-related artifacts, and print next steps.

EXAMPLE_IOS_DIR="packages/example/ios"
cd "$(dirname "$0")/.."
ROOT="$(pwd)"
cd "$ROOT/$EXAMPLE_IOS_DIR"

echo "Preparing example iOS project for SPM migration in: $PWD"

# Backup existing workspace if exists
if [ -d "Runner.xcworkspace" ]; then
  BACKUP=Runner.xcworkspace.cocoapods_backup_$(date +%s)
  echo "Backing up Runner.xcworkspace -> $BACKUP"
  mv Runner.xcworkspace "$BACKUP"
fi

# Remove Pods directory if present (safe to do; this can be re-created by CocoaPods but we are migrating away)
if [ -d "Pods" ]; then
  echo "Removing Pods/ directory"
  rm -rf Pods
fi

# Remove Podfile and Podfile.lock if present (they won't affect SPM but we clean up)
if [ -f "Podfile" ]; then
  echo "Removing Podfile"
  mv Podfile Podfile.cocoapods_backup
fi
if [ -f "Podfile.lock" ]; then
  echo "Removing Podfile.lock"
  mv Podfile.lock Podfile.lock.cocoapods_backup
fi

# Remove CocoaPods generated workspace entry if any
WORKSPACE_FILE="Runner.xcworkspace/contents.xcworkspacedata"
if [ -f "$WORKSPACE_FILE" ]; then
  echo "Cleaning workspace file to remove Pods references"
  # Overwrite with a minimal workspace containing only project ref
  cat > Runner.xcworkspace/contents.xcworkspacedata <<'XML'
<?xml version="1.0" encoding="UTF-8"?>
<Workspace
   version = "1.0">
   <FileRef
      location = "group:Runner.xcodeproj">
   </FileRef>
</Workspace>
XML
fi

# Final instructions
cat <<'EOF'

Done basic cleanup. Next manual steps (open Xcode and finish SPM integration):

1) Open the example project in Xcode:
   open Runner.xcodeproj

2) In Xcode: File → Add Packages…
   - Add the upstream ML Kit SwiftPM URL: https://github.com/d-date/google-mlkit-swiftpm
   - Choose a suitable version (>= 9.0.0)
   - Select the ML Kit products you need for the example (e.g. MLKitBarcodeScanning, MLKitTextRecognition, MLKitImageLabeling, etc.) and add them to the Runner target.

3) If you need to reference the local plugin packages in this repository (for local development), add them as local packages in Xcode:
   - File → Add Packages… → Add Local Package...
   - Select packages/google_mlkit_commons/ios/google_mlkit_commons
   - Also add any packages you want to debug directly, e.g. packages/google_mlkit_barcode_scanning/ios/google_mlkit_barcode_scanning

4) Remove any Pod-related build phases or script phases (unlikely after cleanup) and ensure the Runner target's iOS Deployment Target is >= 15.5.

5) (Optional) Resolve package dependencies from terminal:
   xcodebuild -resolvePackageDependencies -project Runner.xcodeproj

If you want, I can try to add the SPM package references programmatically, but this script intentionally stops here to avoid making fragile changes to the Xcode project file. Open an issue or ask me to proceed with fully-automated package injection.

EOF

