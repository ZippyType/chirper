#!/bin/bash

# Chirper App - Run Script
# Usage: ./run.sh [build|run|analyze]


set -e

cd "$(dirname "$0")"

case "${1:-run}" in
  build)
    echo "Building debug APK..."
    flutter build apk --debug
    echo "✅ Built: build/app/outputs/flutter-apk/app-debug.apk"
    ;;
  run)
    echo "Running app on connected device/emulator..."
    flutter run -d emulator-5554
    ;;
  analyze)
    echo "Analyzing code..."
    flutter analyze --no-fatal-infos
    ;;
  clean)
    echo "Cleaning build..."
    flutter clean
    flutter pub get
    ;;
  *)
    echo "Usage: ./run.sh {build|run|analyze|clean}"
    exit 1
    ;;
esac