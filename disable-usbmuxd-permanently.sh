#!/bin/bash

# Permanently Disable usbmuxd for iPhone VM Passthrough
# This will prevent usbmuxd from ever starting automatically

echo "========================================="
echo "Permanently Disable usbmuxd"
echo "========================================="
echo ""
echo "⚠️  WARNING: After this, you won't be able to access"
echo "   iPhone from Linux - it will ONLY work with macOS VM"
echo ""
read -p "Continue? (y/n) " -n 1 -r
echo ""

if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo "Cancelled."
    exit 1
fi

echo ""
echo "1. Stopping usbmuxd service..."
sudo systemctl stop usbmuxd.service 2>/dev/null
sudo pkill -9 usbmuxd

echo "2. Disabling usbmuxd from auto-start..."
sudo systemctl disable usbmuxd.service 2>/dev/null

echo "3. Masking usbmuxd (prevents any activation)..."
sudo systemctl mask usbmuxd.service

echo "4. Creating udev rule to set iPhone permissions..."
sudo tee /etc/udev/rules.d/99-iphone-vm.rules > /dev/null << 'EOF'
# Allow VM access to iPhone without usbmuxd interference
SUBSYSTEM=="usb", ATTR{idVendor}=="05ac", ATTR{idProduct}=="12a8", MODE="0666", GROUP="plugdev", ENV{USBMUXD_DISABLE}="1"
EOF

echo "5. Reloading udev rules..."
sudo udevadm control --reload-rules
sudo udevadm trigger

echo ""
echo "========================================="
echo "✅ usbmuxd Permanently Disabled"
echo "========================================="
echo ""
echo "Next steps:"
echo "1. Unplug and replug your iPhone X"
echo "2. Unlock it"
echo "3. Start the VM: cd OSX-KVM && ./start-macos.sh"
echo ""
echo "To re-enable usbmuxd in the future:"
echo "  sudo systemctl unmask usbmuxd.service"
echo "  sudo systemctl enable usbmuxd.service"
echo "  sudo rm /etc/udev/rules.d/99-iphone-vm.rules"
echo ""
