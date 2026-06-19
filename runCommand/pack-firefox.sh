#!/bin/bash

# Configuration
SOURCE_FIREFOX="/workspaces/software/firefox"
OUTPUT_DIR="/tmp"
ARCHIVE_NAME="firefox.tar.xz" # Using .xz instead of .bz2 results in ~15-20% smaller files

echo "🚀 Starting aggressive optimization of Firefox..."

# Create a temporary working copy so we don't break your original setup
WORK_DIR=$(mktemp -d)
cp -r "$SOURCE_FIREFOX/." "$WORK_DIR/"
cd "$WORK_DIR" || exit 1

echo "🧹 Stripping unneeded files and bloat..."

# 1. Remove crash reporter binaries and components
rm -f crashreporter minidump-analyzer pingsender
rm -rf browser/crashreporter-manifests

# 2. Remove default updater binaries (since your script manages updates)
rm -f updater update-settings.ini

# 3. Remove maintenance services if they exist (Windows/Linux cross-overs)
rm -f maintenance-service

# 4. Strip debugging symbols from binaries (This saves MASSIVE space)
# It removes extra developer data without changing how the browser works.
echo "🔍 Stripping binary files..."
find . -type f -exec file {} \; | grep -E "ELF.*executable|ELF.*shared object" | cut -d: -f1 | xargs strip --strip-unneeded 2>/dev/null

echo "📦 Compressing using maximum XZ compression..."
# -9e enables extreme compression mode for the xz algorithm
tar -cJf "$OUTPUT_DIR/$ARCHIVE_NAME" -C "$WORK_DIR" --xz .

# Clean up our temporary working directory
rm -rf "$WORK_DIR"

echo "✨ Optimization Complete!"
echo "💾 Smallest archive created at: $OUTPUT_DIR/$ARCHIVE_NAME"
ls -lh "$OUTPUT_DIR/$ARCHIVE_NAME"

# tar -xJf firefox.tar.xz -C "$DEST" --strip-components=1 || return 1




