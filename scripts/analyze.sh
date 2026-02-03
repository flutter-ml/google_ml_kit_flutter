#!/bin/bash

cd "$(dirname "$0")/.."

dart format --set-exit-if-changed .
flutter analyze .
