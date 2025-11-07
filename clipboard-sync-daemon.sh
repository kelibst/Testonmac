#!/bin/bash
# Clipboard Auto-Sync Daemon
# Automatically syncs clipboard between Deepin host and macOS VM every 2 seconds

INTERVAL=2  # seconds between syncs
SSH_PORT=2222
SSH_HOST="localhost"
LAST_HOST_CLIP=""
LAST_VM_CLIP=""

echo "🔄 Starting Clipboard Auto-Sync Daemon..."
echo "Syncing every ${INTERVAL} seconds"
echo "Press Ctrl+C to stop"
echo ""

while true; do
    # Get current host clipboard
    CURRENT_HOST_CLIP=$(xclip -selection clipboard -o 2>/dev/null)

    # Get current VM clipboard (via SSH)
    CURRENT_VM_CLIP=$(ssh -p $SSH_PORT -o ConnectTimeout=1 -o StrictHostKeyChecking=no $SSH_HOST pbpaste 2>/dev/null)

    # If host clipboard changed, sync to VM
    if [ "$CURRENT_HOST_CLIP" != "$LAST_HOST_CLIP" ] && [ -n "$CURRENT_HOST_CLIP" ]; then
        echo "$(date '+%H:%M:%S') - 📋 Syncing Host → macOS"
        echo "$CURRENT_HOST_CLIP" | ssh -p $SSH_PORT -o StrictHostKeyChecking=no $SSH_HOST pbcopy 2>/dev/null
        LAST_HOST_CLIP="$CURRENT_HOST_CLIP"
        LAST_VM_CLIP="$CURRENT_HOST_CLIP"  # Prevent loop
    fi

    # If VM clipboard changed, sync to host
    if [ "$CURRENT_VM_CLIP" != "$LAST_VM_CLIP" ] && [ -n "$CURRENT_VM_CLIP" ]; then
        echo "$(date '+%H:%M:%S') - 📋 Syncing macOS → Host"
        echo "$CURRENT_VM_CLIP" | xclip -selection clipboard 2>/dev/null
        LAST_VM_CLIP="$CURRENT_VM_CLIP"
        LAST_HOST_CLIP="$CURRENT_VM_CLIP"  # Prevent loop
    fi

    sleep $INTERVAL
done
