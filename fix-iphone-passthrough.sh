#!/bin/bash

# Fix iPhone USB Passthrough - Aggressively Stop usbmuxd
# This script completely stops usbmuxd and prevents it from restarting

echo "========================================="
echo "iPhone USB Passthrough Fix"
echo "========================================="
echo ""

# 1. Stop the systemd service
echo "1. Stopping usbmuxd systemd service..."
sudo systemctl stop usbmuxd.service 2>/dev/null
sudo systemctl stop usbmuxd.socket 2>/dev/null

# 2. Kill any running usbmuxd processes
echo "2. Killing any running usbmuxd processes..."
sudo pkill -9 usbmuxd

# 3. Wait a moment
sleep 1

# 4. Verify it's dead
if ps aux | grep -i usbmuxd | grep -v grep > /dev/null; then
    echo "⚠️  WARNING: usbmuxd is still running!"
    ps aux | grep -i usbmuxd | grep -v grep
else
    echo "✅ usbmuxd successfully stopped"
fi

echo ""
echo "3. Unbinding iPhone from Linux driver..."

# Find the iPhone device
IPHONE_BUS=$(lsusb | grep -i apple | grep -i "12a8" | awk '{print $2}')
IPHONE_DEV=$(lsusb | grep -i apple | grep -i "12a8" | awk '{print $4}' | tr -d ':')

if [ -z "$IPHONE_BUS" ] || [ -z "$IPHONE_DEV" ]; then
    echo "⚠️  iPhone not detected. Make sure it's plugged in and unlocked."
    exit 1
fi

echo "   Found iPhone at Bus $IPHONE_BUS Device $IPHONE_DEV"

# Unbind from Linux USB driver (this releases the BUSY lock)
USB_PATH="/sys/bus/usb/devices/${IPHONE_BUS}-*"
for device_path in $USB_PATH; do
    if [ -e "$device_path/driver/unbind" ]; then
        DEVICE_NAME=$(basename "$device_path")
        echo "   Unbinding device: $DEVICE_NAME"
        echo "$DEVICE_NAME" | sudo tee "$device_path/driver/unbind" > /dev/null 2>&1
    fi
done

echo ""
echo "========================================="
echo "✅ iPhone should now be ready for VM"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Start the VM: cd OSX-KVM && ./start-macos.sh"
echo "2. Unlock your iPhone X"
echo "3. Tap 'Trust' when prompted"
echo ""
