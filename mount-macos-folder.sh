#!/bin/bash
# Mount macOS folder on Deepin via SSHFS

MACOS_USER="kelibst"
MACOS_PATH="/Users/kelibst/Desktop"
LOCAL_MOUNT="$HOME/macos-files"

echo "🔗 Mounting macOS folder via SSHFS..."

# Check if sshfs is installed
if ! command -v sshfs &> /dev/null; then
    echo "❌ sshfs is not installed"
    echo "Install it with: sudo apt-get install sshfs"
    exit 1
fi

# Create mount point
mkdir -p "$LOCAL_MOUNT"

# Check if already mounted
if mountpoint -q "$LOCAL_MOUNT"; then
    echo "✅ Already mounted at $LOCAL_MOUNT"
    exit 0
fi

# Mount macOS folder
sshfs -p 2222 "$MACOS_USER@localhost:$MACOS_PATH" "$LOCAL_MOUNT"

if [ $? -eq 0 ]; then
    echo "✅ Successfully mounted!"
    echo "📁 Access macOS files at: $LOCAL_MOUNT"
    echo ""
    echo "To unmount: fusermount -u $LOCAL_MOUNT"
else
    echo "❌ Failed to mount"
fi
