#!/bin/bash
# Build and deploy script for Chirper

cd "$(dirname "$0")"

# Add web platform if not exists
if [ ! -d "web/index.html" ]; then
    echo "Adding web platform..."
    flutter create . --platforms web
fi

echo "Building web..."
flutter build web --no-tree-shake-icons

echo "Copying to web folder..."
rm -rf web/*
cp -r build/web/* .

echo "Committing..."
git add -A
git commit -m "Build $(date)" && git push

echo "Done! https://zippytype.github.io/chirper/"
