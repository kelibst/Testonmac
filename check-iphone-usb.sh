#!/bin/bash

# iPhone USB Detection Helper Script
# Helps identify your iPhone's USB IDs for VM passthrough

echo "========================================="
echo "iPhone USB Detection Tool"
echo "========================================="
echo ""

# Check if any Apple devices are connected
echo "🔍 Checking for Apple devices..."
apple_devices=$(lsusb | grep -i apple)

if [ -z "$apple_devices" ]; then
    echo "❌ No Apple devices detected"
    echo ""
    echo "Please:"
    echo "  1. Plug in your iPhone X"
    echo "  2. Unlock your iPhone"
    echo "  3. Run this script again"
    echo ""
    exit 1
fi

echo "✅ Apple device(s) found:"
echo ""
echo "$apple_devices"
echo ""

# Extract vendor and product IDs
echo "========================================="
echo "USB IDs for VM Configuration"
echo "========================================="
echo ""

while IFS= read -r line; do
    # Extract Bus, Device, and ID
    bus=$(echo "$line" | grep -oP 'Bus \K\d+')
    device=$(echo "$line" | grep -oP 'Device \K\d+')
    id=$(echo "$line" | grep -oP 'ID \K[0-9a-f:]+')
    vendor_id=$(echo "$id" | cut -d':' -f1)
    product_id=$(echo "$id" | cut -d':' -f2)

    echo "Device: $line"
    echo "  └─ Vendor ID:  0x$vendor_id (use this in start-macos.sh)"
    echo "  └─ Product ID: 0x$product_id (use this in start-macos.sh)"
    echo "  └─ Bus: $bus, Device: $device"
    echo ""

    # Generate the QEMU command line
    echo "📋 Add this to your start-macos.sh:"
    echo ""
    echo "    -device nec-usb-xhci,id=xhci \\"
    echo "    -device usb-host,vendorid=0x$vendor_id,productid=0x$product_id,id=iphone,bus=xhci.0 \\"
    echo ""
    echo "  OR (using bus/device numbers - less reliable):"
    echo ""
    echo "    -device usb-host,hostbus=$bus,hostaddr=$device,id=iphone,bus=xhci.0 \\"
    echo ""
done <<< "$apple_devices"

# Check if usbmuxd is running (will interfere with passthrough)
echo "========================================="
echo "Checking for USB Service Conflicts"
echo "========================================="
echo ""

if systemctl is-active --quiet usbmuxd.service; then
    echo "⚠️  WARNING: usbmuxd.service is running"
    echo "   This will prevent USB passthrough to the VM"
    echo ""
    echo "   To disable temporarily:"
    echo "   sudo systemctl stop usbmuxd.service"
    echo "   sudo systemctl stop usbmuxd.socket"
    echo ""
    echo "   To disable permanently (recommended):"
    echo "   See IPHONE-USB-PASSTHROUGH-GUIDE.md Step 1"
    echo ""
else
    echo "✅ usbmuxd.service is stopped (good for VM passthrough)"
    echo ""
fi

# Get detailed device info
echo "========================================="
echo "Detailed Device Information"
echo "========================================="
echo ""

lsusb -v -d 05ac: 2>/dev/null | grep -E "idVendor|idProduct|iProduct|iManufacturer|iSerial" | head -20

echo ""
echo "========================================="
echo "Next Steps"
echo "========================================="
echo ""
echo "1. Note the Vendor ID and Product ID above"
echo "2. Follow IPHONE-USB-PASSTHROUGH-GUIDE.md Step 3"
echo "3. Add the USB passthrough lines to start-macos.sh"
echo "4. Start the VM and test with: xcrun xctrace list devices"
echo ""
