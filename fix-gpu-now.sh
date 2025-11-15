#!/bin/bash
# EMERGENCY FIX: Restore GPU to Linux
# Run this to get your Linux desktop back

echo "========================================"
echo "  EMERGENCY GPU RESTORATION"
echo "========================================"
echo ""

if [ "$EUID" -ne 0 ]; then
    echo "ERROR: Must run as root"
    echo "Run: sudo ./fix-gpu-now.sh"
    exit 1
fi

echo "Step 1: Removing VFIO configuration..."
rm -f /etc/modprobe.d/vfio.conf
rm -f /etc/modprobe.d/blacklist-gpu.conf
rm -f /etc/modules-load.d/vfio.conf
echo "✅ VFIO configs removed"

echo ""
echo "Step 2: Restoring GRUB (removing IOMMU)..."
if [ -f /etc/default/grub.backup.* ]; then
    LATEST_BACKUP=$(ls -t /etc/default/grub.backup.* | head -1)
    cp "$LATEST_BACKUP" /etc/default/grub
    echo "✅ GRUB restored from backup: $LATEST_BACKUP"
else
    # Manually remove IOMMU parameters
    sed -i 's/intel_iommu=on iommu=pt //g' /etc/default/grub
    echo "✅ IOMMU parameters removed from GRUB"
fi

echo ""
echo "Step 3: Updating GRUB..."
update-grub

echo ""
echo "Step 4: Updating initramfs..."
update-initramfs -u

echo ""
echo "========================================"
echo "  FIX COMPLETE!"
echo "========================================"
echo ""
echo "Your GPU will work normally on next reboot."
echo ""
echo "IMPORTANT: Reboot now to restore your desktop!"
echo ""
read -p "Reboot now? (yes/no): " REBOOT

if [ "$REBOOT" = "yes" ]; then
    echo "Rebooting in 3 seconds..."
    sleep 3
    reboot
else
    echo ""
    echo "Please reboot manually: sudo reboot"
fi
