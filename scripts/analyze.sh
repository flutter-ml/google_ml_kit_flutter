#!/bin/bash
set -e

cd "$(dirname "$0")/.."

dart format --set-exit-if-changed .
flutter analyze .

# Lint Kotlin code with ktlint (https://github.com/pinterest/ktlint)
if ! command -v ktlint &>/dev/null; then
    echo "ktlint is not installed. Install it with:"
    echo "  brew install ktlint"
    exit 1
else
    ktlint --format
fi

# Lint Swift code (iOS plugins) with SwiftLint (https://github.com/realm/SwiftLint)
# Apple Silicon Homebrew installs to /opt/homebrew/bin
if [[ "$(uname -m)" == arm64 ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi
if ! command -v swiftlint &>/dev/null; then
    echo "swiftlint is not installed. Install it with:"
    echo "  brew install swiftlint"
    exit 1
fi
swiftlint lint --fix
SWIFTLINT_OUTPUT=$(swiftlint lint 2>&1) || true
echo "$SWIFTLINT_OUTPUT"
if echo "$SWIFTLINT_OUTPUT" | grep -qE "Found [1-9][0-9]* violations?"; then
    exit 1
fi

printf '\033[34m%s\033[0m\n' "All checks passed: formatting and linting successful."
