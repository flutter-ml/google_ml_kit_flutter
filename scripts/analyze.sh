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

printf '\033[34m%s\033[0m\n' "All checks passed: formatting and linting successful."
