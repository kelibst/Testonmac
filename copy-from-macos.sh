#!/bin/bash
# Copy clipboard from macOS VM to Deepin Host

# Check if VM SSH is accessible
if ! nc -z localhost 2222 2>/dev/null; then
    echo "❌ Error: macOS VM is not running or SSH is not accessible"
    echo "   Make sure the VM is started and try again"
    exit 1
fi

# Get macOS clipboard via SSH and copy to host clipboard
ssh -p 2222 -o StrictHostKeyChecking=no localhost pbpaste 2>/dev/null | xclip -selection clipboard

if [ $? -eq 0 ]; then
    echo "✅ Clipboard copied from macOS VM to host"
else
    echo "⚠️  SSH not configured yet. First, set up SSH in macOS:"
    echo "   1. In macOS: System Settings > General > Sharing"
    echo "   2. Enable 'Remote Login'"
    echo "   3. Run this script again"
fi
