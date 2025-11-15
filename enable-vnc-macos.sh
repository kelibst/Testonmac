#!/bin/bash
# Enable VNC Server in macOS VM
# Run this script inside macOS VM to enable Screen Sharing

echo "========================================"
echo "  Enabling VNC Server in macOS"
echo "========================================"
echo ""

echo "Step 1: Enabling Screen Sharing..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -activate \
  -configure \
  -access -on \
  -restart -agent -privs -all

echo ""
echo "Step 2: Enabling VNC (legacy password mode)..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure \
  -clientopts \
  -setvnclegacy -vnclegacy yes

echo ""
echo "Step 3: Setting VNC password..."
echo "Please enter a VNC password (will be used to connect from Linux):"
read -s VNC_PASSWORD

sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -configure \
  -clientopts \
  -setvncpw -vncpw "$VNC_PASSWORD"

echo ""
echo "Step 4: Restarting Screen Sharing service..."
sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart \
  -restart -agent

echo ""
echo "========================================"
echo "  VNC Server Enabled!"
echo "========================================"
echo ""
echo "Connection Details:"
echo "  From Linux: vncviewer localhost:5900"
echo "  Password: (the one you just set)"
echo ""
echo "Note: You must restart the VM for port forwarding to take effect!"
echo ""
