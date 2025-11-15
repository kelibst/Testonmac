#!/bin/bash

# Start macOS VM with iPhone X USB Passthrough
# This script automatically detects the iPhone and passes it to the VM

echo "========================================="
echo "macOS VM with iPhone X USB Passthrough"
echo "========================================="
echo ""

# 1. Kill usbmuxd
echo "1. Stopping usbmuxd..."
sudo pkill -9 usbmuxd 2>/dev/null
sudo systemctl stop usbmuxd.service 2>/dev/null

# 2. Wait a moment for device to settle
sleep 2

# 3. Detect iPhone
echo "2. Detecting iPhone X..."
IPHONE_INFO=$(lsusb | grep -i "05ac:12a8")

if [ -z "$IPHONE_INFO" ]; then
    echo "❌ iPhone X not detected!"
    echo ""
    echo "Please:"
    echo "  1. Plug in your iPhone X"
    echo "  2. Unlock it"
    echo "  3. Run this script again"
    echo ""
    exit 1
fi

# Extract bus and device numbers
BUS=$(echo "$IPHONE_INFO" | awk '{print $2}')
DEVICE=$(echo "$IPHONE_INFO" | awk '{print $4}' | tr -d ':')

echo "   ✅ Found iPhone X on Bus $BUS Device $DEVICE"
echo ""

# 4. Start VM with dynamic USB passthrough
echo "3. Starting macOS VM..."
echo ""

cd ~/Desktop/projects/Testonmac/OSX-KVM

# Clean environment variables (from original script)
for var in $(env | grep -i snap | cut -d= -f1); do
    unset $var 2>/dev/null
done
unset GTK_PATH GTK_EXE_PREFIX GTK_DATA_PREFIX GDK_PIXBUF_MODULEDIR GDK_PIXBUF_MODULE_FILE GIO_MODULE_DIR GTK_IM_MODULE_FILE GSETTINGS_SCHEMA_DIR LOCPATH LD_LIBRARY_PATH

export PATH=/usr/local/bin:/usr/bin:/bin:/usr/local/games:/usr/games:/sbin:/usr/sbin

ALLOCATED_RAM="12288"
CPU_SOCKETS="1"
CPU_CORES="8"
CPU_THREADS="16"
REPO_PATH="."
OVMF_DIR="."

echo "========================================"
echo "  Starting macOS Sonoma Virtual Machine"
echo "========================================"
echo "RAM: ${ALLOCATED_RAM}MB (12GB)"
echo "CPU: ${CPU_CORES} cores / ${CPU_THREADS} threads"
echo "USB: iPhone X on Bus $BUS Device $DEVICE"
echo "========================================"
echo ""

/usr/bin/qemu-system-x86_64 \
  -enable-kvm -m "$ALLOCATED_RAM" -cpu host,kvm=on,+invtsc,+hypervisor,+avx,+avx2,+aes,+ssse3,+sse4.1,+sse4.2 \
  -machine q35,accel=kvm,kernel_irqchip=on \
  -rtc base=localtime,clock=host \
  -global kvm-pit.lost_tick_policy=discard \
  -device qemu-xhci,id=xhci \
  -device usb-kbd,bus=xhci.0 -device usb-tablet,bus=xhci.0 \
  -device usb-host,hostbus=$BUS,hostaddr=$DEVICE,id=iphone,bus=xhci.0 \
  -smp "$CPU_THREADS",cores="$CPU_CORES",sockets="$CPU_SOCKETS" \
  -device usb-ehci,id=ehci \
  -device isa-applesmc,osk="ourhardworkbythesewordsguardedpleasedontsteal(c)AppleComputerInc" \
  -drive if=pflash,format=raw,readonly=on,file="$REPO_PATH/$OVMF_DIR/OVMF_CODE.fd" \
  -drive if=pflash,format=raw,file="$REPO_PATH/$OVMF_DIR/OVMF_VARS-1920x1080.fd" \
  -smbios type=2 \
  -device ich9-intel-hda -device hda-duplex \
  -device ich9-ahci,id=sata \
  -drive id=OpenCoreBoot,if=none,snapshot=on,format=qcow2,file="$REPO_PATH/OpenCore/OpenCore.qcow2" \
  -device ide-hd,bus=sata.0,drive=OpenCoreBoot,bootindex=1 \
  -drive id=InstallMedia,if=none,file="$REPO_PATH/BaseSystem.img",format=raw \
  -device ide-hd,bus=sata.1,drive=InstallMedia \
  -drive id=MacHDD,if=none,file="$REPO_PATH/mac_hdd_ng.img",format=qcow2,cache=writeback \
  -device ide-hd,bus=sata.2,drive=MacHDD \
  -netdev user,id=net0,hostfwd=tcp::2222-:22 -device virtio-net-pci,netdev=net0,id=net0,mac=52:54:00:c9:18:27 \
  -virtfs local,path=$REPO_PATH/../shared,mount_tag=sharedfolder,security_model=mapped-xattr,id=sharedfolder \
  -monitor stdio \
  -device VGA,vgamem_mb=256 \
  -display gtk,zoom-to-fit=off \
  -global ICH9-LPC.disable_s3=1 \
  -global ICH9-LPC.disable_s4=1
