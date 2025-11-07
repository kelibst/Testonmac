#!/bin/bash
# Setup NFS Share for macOS VM
# This script sets up an NFS server on Deepin host for the macOS guest

SHARED_DIR="/home/kelib/Desktop/projects/Testonmac/shared"
NFS_EXPORTS="/etc/exports"

echo "🗂️  Setting up NFS Share for macOS VM..."
echo ""

# Install NFS server if not installed
if ! dpkg -l | grep -q nfs-kernel-server; then
    echo "📦 Installing NFS server..."
    echo "Please run: sudo apt-get install -y nfs-kernel-server"
    echo "Then run this script again."
    exit 1
fi

echo "✅ NFS server is installed"
echo ""

# Create shared directory if it doesn't exist
if [ ! -d "$SHARED_DIR" ]; then
    mkdir -p "$SHARED_DIR"
    echo "✅ Created shared directory: $SHARED_DIR"
fi

# Add export entry to /etc/exports
echo "📝 Configuring NFS exports..."
echo ""
echo "Add this line to /etc/exports (requires sudo):"
echo ""
echo "$SHARED_DIR 10.0.2.0/24(rw,sync,no_subtree_check,all_squash,anonuid=$(id -u),anongid=$(id -g))"
echo ""
echo "Run these commands:"
echo "  sudo nano /etc/exports"
echo "  (Add the line above)"
echo "  sudo exportfs -ra"
echo "  sudo systemctl restart nfs-kernel-server"
echo ""
echo "Then in macOS, you can mount with:"
echo "  sudo mkdir -p /Volumes/SharedFolder"
echo "  sudo mount -t nfs -o resvport 10.0.2.2:$SHARED_DIR /Volumes/SharedFolder"
