#!/bin/bash
# Copy clipboard from Deepin Host to macOS VM

# Get current clipboard content
CLIP_CONTENT=$(xclip -selection clipboard -o)

# Check if VM SSH is accessible
if ! nc -z localhost 2222 2>/dev/null; then
    echo "❌ Error: macOS VM is not running or SSH is not accessible"
    echo "   Make sure the VM is started and try again"
    exit 1
fi

# Copy to macOS clipboard via SSH
echo "$CLIP_CONTENT" | ssh -p 2222 -o StrictHostKeyChecking=no localhost pbcopy 2>/dev/null

if [ $? -eq 0 ]; then
    echo "✅ Clipboard copied to macOS VM"
else
    echo "⚠️  SSH not configured yet. First, set up SSH in macOS:"
    echo "   1. In macOS: System Settings > General > Sharing"
    echo "   2. Enable 'Remote Login'"
    echo "   3. Run this script again"
fi
