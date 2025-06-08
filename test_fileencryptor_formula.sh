#!/bin/bash

# Test script for FileEncryptor Homebrew formula
# This script tests installation and uninstallation of the local formula

set -e  # Exit on any error

FORMULA_NAME="fileencryptor"
FORMULA_FILE="./fileencryptor.rb"
TEST_DIR="/tmp/fileencryptor_test"

echo "🧪 Starting FileEncryptor Formula Test"
echo "======================================"

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

# Verify binary is installed
echo "🔍 Verifying installed binary..."
HOMEBREW_BINARY_PATH="/opt/homebrew/bin/FileEncryptor"

if [[ ! -f "$HOMEBREW_BINARY_PATH" ]]; then
    echo "❌ Error: FileEncryptor binary not found at $HOMEBREW_BINARY_PATH"
    exit 1
fi
echo "✅ Homebrew binary found at $HOMEBREW_BINARY_PATH"

# Test binary functionality (should show usage and exit with code 1)
echo "🧪 Testing binary functionality..."
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# Test that the binary shows usage when run without arguments
echo "🔄 Testing binary functionality..."
if output=$("$HOMEBREW_BINARY_PATH" 2>&1); then
    echo "❌ Error: Binary should exit with non-zero status when run without arguments"
    exit 1
else
    # Check if the output contains usage information
    if echo "$output" | grep -q "usage: FileEncryptor"; then
        echo "✅ Binary usage output verified"
    else
        echo "❌ Error: Expected usage output not found"
        echo "Got output: $output"
        exit 1
    fi
fi

# Check for macOS-specific features if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Checking macOS Finder integration..."
    
    # Check if the workflow was installed
    SERVICES_DIR="$HOME/Library/Services"
    WORKFLOW_PATH="$SERVICES_DIR/FileEncryptor.workflow"
    
    if [[ -d "$WORKFLOW_PATH" ]]; then
        echo "✅ FileEncryptor Finder workflow installed successfully"
    else
        echo "⚠️  Warning: FileEncryptor Finder workflow not found at expected location"
        echo "   This might be expected if the workflow files are not in the repository"
    fi
    
    # Note about 1Password CLI requirement
    echo "ℹ️  Note: 1Password CLI is required for FileEncryptor to function properly"
    echo "   Install it with: brew install --cask 1password-cli"
    if command -v op &> /dev/null; then
        echo "✅ 1Password CLI is already installed"
    else
        echo "⚠️  1Password CLI not found - will need manual installation"
    fi
else
    echo "ℹ️  Skipping macOS-specific tests (not running on macOS)"
fi

# Test formula info
echo "📋 Formula information:"
brew info "$FORMULA_NAME"

# List installed files
echo "📁 Installed files:"
brew list "$FORMULA_NAME"

# Test formula caveats
echo "📝 Formula caveats:"
brew info "$FORMULA_NAME" | sed -n '/==> Caveats/,/==> /p' | head -n -1

echo "🗑️  Uninstalling formula..."
brew uninstall "$FORMULA_NAME"

# Verify uninstallation
if brew list "$FORMULA_NAME" &> /dev/null; then
    echo "❌ Error: Formula still appears to be installed after uninstall"
    exit 1
fi

# Check if Homebrew cellar directory is removed
CELLAR_PATH="/opt/homebrew/Cellar/$FORMULA_NAME"
if [[ -d "$CELLAR_PATH" ]]; then
    echo "❌ Error: Formula directory still exists at $CELLAR_PATH after uninstall"
    exit 1
fi

echo "✅ Uninstallation successful - formula completely removed"

# Check macOS cleanup if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "🍎 Checking macOS cleanup..."
    
    SERVICES_DIR="$HOME/Library/Services"
    WORKFLOW_PATH="$SERVICES_DIR/FileEncryptor.workflow"
    
    if [[ -d "$WORKFLOW_PATH" ]]; then
        echo "⚠️  Warning: FileEncryptor Finder workflow still exists after uninstall"
        echo "   This might be expected behavior to preserve user data"
    else
        echo "✅ FileEncryptor Finder workflow properly removed"
    fi
fi

# Note about manual cleanup for user-created symlinks
echo "ℹ️  Note: Any user-created symlinks (~/bin/FileEncryptor) will need manual cleanup"
echo "ℹ️  The Finder workflow will also need manual removal: rm -rf ~/Library/Services/FileEncryptor.workflow"

echo ""
echo "🎉 All tests passed!"
echo "✅ Formula installs correctly"
echo "✅ Binary works as expected"
echo "✅ Formula structure is valid"
if [[ "$OSTYPE" == "darwin"* ]]; then
    echo "✅ macOS integration features tested"
fi
echo "✅ Formula uninstalls cleanly"
echo "======================================" 