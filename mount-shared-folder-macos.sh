#!/bin/bash
# Mount Shared Folder in macOS
# Run this script inside your macOS VM to mount the shared folder

MOUNT_TAG="sharedfolder"
MOUNT_POINT="/Volumes/SharedFolder"

echo "🗂️  Mounting Shared Folder..."

# Create mount point if it doesn't exist
if [ ! -d "$MOUNT_POINT" ]; then
    echo "Creating mount point: $MOUNT_POINT"
    sudo mkdir -p "$MOUNT_POINT"
fi

# Check if already mounted
if mount | grep -q "$MOUNT_POINT"; then
    echo "✅ Shared folder is already mounted at $MOUNT_POINT"
    exit 0
fi

# Mount the 9p filesystem
echo "Mounting $MOUNT_TAG to $MOUNT_POINT..."
sudo mount_9p "$MOUNT_TAG" "$MOUNT_POINT"

if [ $? -eq 0 ]; then
    echo "✅ Successfully mounted shared folder!"
    echo "📁 Access it at: $MOUNT_POINT"
    echo ""
    echo "You can now:"
    echo "  - Drag and drop files between host and guest"
    echo "  - Open files directly from both systems"
    echo "  - Create new files in the shared folder"
else
    echo "❌ Failed to mount shared folder"
    echo "Make sure the VM was started with virtfs support"
fi
