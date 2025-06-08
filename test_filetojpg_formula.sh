#!/bin/bash

# Test script for FileToJPG Homebrew formula
# This script tests installation and uninstallation of the local formula

set -e  # Exit on any error

FORMULA_NAME="filetojpg"
FORMULA_FILE="./filetojpg.rb"
TEST_DIR="/tmp/filetojpg_test"

echo "🧪 Starting FileToJPG Formula Test"
echo "=================================="

# Check if formula file exists
if [[ ! -f "$FORMULA_FILE" ]]; then
    echo "❌ Error: Formula file $FORMULA_FILE not found!"
    exit 1
fi

# Function to cleanup on exit
cleanup() {
    echo "🧹 Cleaning up..."
    rm -rf "$TEST_DIR"
    # Try to uninstall if it's installed
    if brew list "$FORMULA_NAME" &> /dev/null; then
        echo "🗑️  Uninstalling $FORMULA_NAME..."
        brew uninstall "$FORMULA_NAME" || true
    fi
}

# Set trap to cleanup on script exit
trap cleanup EXIT

echo "📦 Installing formula from local file..."
brew install "$FORMULA_FILE"

echo "✅ Installation completed!"

# Verify binaries are installed
echo "🔍 Verifying installed binaries..."
if ! command -v FileToJPG &> /dev/null; then
    echo "❌ Error: FileToJPG binary not found in PATH"
    exit 1
fi

if ! command -v JPGToFile &> /dev/null; then
    echo "❌ Error: JPGToFile binary not found in PATH"
    exit 1
fi

echo "✅ Both binaries found in PATH"

# Test functionality
echo "🧪 Testing functionality..."
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Create a test file
echo "Hello, Homebrew Test!" > test.txt
echo "📝 Created test file: test.txt"

# Test FileToJPG
echo "🔄 Converting file to JPG..."
FileToJPG test.txt

if [[ ! -f "test.txt.JPG" ]]; then
    echo "❌ Error: JPG file was not created"
    exit 1
fi

echo "✅ JPG file created successfully"

# Remove original file to test extraction
rm test.txt

# Test JPGToFile
echo "🔄 Extracting file from JPG..."
JPGToFile test.txt.JPG

if [[ ! -f "test.txt" ]]; then
    echo "❌ Error: File was not extracted from JPG"
    exit 1
fi

# Verify content
extracted_content=$(cat test.txt)
if [[ "$extracted_content" != "Hello, Homebrew Test!" ]]; then
    echo "❌ Error: Extracted content doesn't match original"
    echo "Expected: 'Hello, Homebrew Test!'"
    echo "Got: '$extracted_content'"
    exit 1
fi

echo "✅ File extraction and content verification successful"

# Test formula info
echo "📋 Formula information:"
brew info "$FORMULA_NAME"

# List installed files
echo "📁 Installed files:"
brew list "$FORMULA_NAME"

echo "🗑️  Uninstalling formula..."
brew uninstall "$FORMULA_NAME"

# Verify uninstallation
if brew list "$FORMULA_NAME" &> /dev/null; then
    echo "❌ Error: Formula still appears to be installed after uninstall"
    exit 1
fi

# Check if Homebrew cellar directory is removed (more reliable than PATH check)
CELLAR_PATH="/opt/homebrew/Cellar/$FORMULA_NAME"
if [[ -d "$CELLAR_PATH" ]]; then
    echo "❌ Error: Formula directory still exists at $CELLAR_PATH after uninstall"
    exit 1
fi

echo "✅ Uninstallation successful - formula completely removed"

# Note about PATH caching
if command -v FileToJPG &> /dev/null || command -v JPGToFile &> /dev/null; then
    echo "ℹ️  Note: Binaries may still appear in PATH due to shell caching."
    echo "ℹ️  This is normal - restart your shell or run 'hash -r' to clear the cache."
fi

echo ""
echo "🎉 All tests passed!"
echo "✅ Formula installs correctly"
echo "✅ Binaries work as expected"
echo "✅ Formula uninstalls cleanly"
echo "==================================" 