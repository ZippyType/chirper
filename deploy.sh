#!/bin/bash
# Build and deploy script for Chirper

echo "Building web..."
flutter build web --no-tree-shake-icons

echo "Copying to web folder..."
rm -rf web/*
cp -r build/web/* .

echo "Committing..."
git add -A
git commit -m "Build $(date)" && git push

echo "Done!"
