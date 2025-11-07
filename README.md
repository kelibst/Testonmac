# macOS on Linux (QEMU/KVM) Setup

A complete setup for running macOS Sonoma in a virtual machine on Debian-based Linux (tested on Deepin OS) using OSX-KVM. This project includes automated clipboard synchronization, shared folders via SSHFS, and optimized performance settings.

## Features

- **Full macOS Sonoma VM** running on QEMU/KVM
- **Passwordless SSH** access to macOS VM
- **Automatic clipboard sync** between host and macOS
- **Shared folders** via SSHFS
- **Optimized performance** with CPU passthrough
- **Desktop launcher** for easy VM startup
- **Complete automation scripts** for setup and daily use

## System Requirements

- **CPU**: Intel CPU with VT-x support (tested on Xeon E5-2670 v3)
- **RAM**: At least 16GB (12GB allocated to VM)
- **Disk**: 256GB+ free space for macOS virtual disk
- **OS**: Debian-based Linux (Deepin, Ubuntu, Debian, etc.)
- **GPU**: Any GPU with 256MB+ VRAM (tested with RX 580)

## Installation

### 1. Install Dependencies

```bash
sudo apt update
sudo apt install -y qemu-kvm qemu-utils python3 python3-pip dmg2img git uml-utilities virt-manager sshfs xclip
```

### 2. Configure User Permissions

```bash
sudo usermod -aG kvm,libvirt,input $USER
```

**Important**: Log out and log back in for group changes to take effect!

### 3. Enable KVM Kernel Modules

```bash
echo "options kvm_intel nested=1 ignore_msrs=1 ept=1" | sudo tee /etc/modprobe.d/kvm.conf
sudo modprobe -r kvm_intel
sudo modprobe kvm_intel
```

Make it persistent:
```bash
echo "kvm_intel" | sudo tee /etc/modules-load.d/kvm.conf
```

### 4. Clone This Repository

```bash
cd ~/Desktop/projects
git clone https://github.com/YOUR_USERNAME/Testonmac.git
cd Testonmac
```

### 5. Download macOS Installer

The OSX-KVM repository is already included. Download the macOS Sonoma installer:

```bash
cd OSX-KVM
./fetch-macOS-v2.py
```

Select **macOS Sonoma** from the menu.

### 6. Convert Installer Image

```bash
dmg2img BaseSystem.dmg BaseSystem.img
```

### 7. Create Virtual Hard Disk

```bash
qemu-img create -f qcow2 mac_hdd_ng.img 256G
```

### 8. Start macOS VM for First Time

```bash
cd ..
./OSX-KVM/start-macos.sh
```

Follow the on-screen macOS installation wizard.

### 9. Enable SSH in macOS

After macOS is installed and running:

1. Open **System Settings**
2. Go to **General** → **Sharing**
3. Enable **Remote Login**
4. Ensure your user is allowed to connect

### 10. Set Up SSH Key Authentication

Generate SSH key on Linux host:

```bash
ssh-keygen -t ed25519 -f ~/.ssh/macos_vm -N "" -C "linux-to-macos-vm"
```

Copy the public key to macOS clipboard (from Linux):

```bash
cat ~/.ssh/macos_vm.pub | xclip -selection clipboard
```

Then use the manual clipboard copy script:

```bash
./copy-to-macos.sh
```

In macOS Terminal, add the key:

```bash
mkdir -p ~/.ssh && chmod 700 ~/.ssh
nano ~/.ssh/authorized_keys
# Paste the key (Cmd+V), then Ctrl+O, Enter, Ctrl+X
chmod 600 ~/.ssh/authorized_keys
```

Test passwordless connection (from Linux):

```bash
ssh -p 2222 YOUR_MACOS_USERNAME@localhost whoami
```

Replace `YOUR_MACOS_USERNAME` with your actual macOS username.

## Usage

### Starting the VM

**Method 1: Command Line**
```bash
cd ~/Desktop/projects/Testonmac
./OSX-KVM/start-macos.sh
```

**Method 2: Desktop Launcher**
Double-click the `Start-macOS-VM.desktop` file on your desktop.

### Clipboard Synchronization

**Auto-sync (recommended):**
```bash
./clipboard-sync-daemon.sh
```

This will sync clipboard between Linux and macOS every 2 seconds. Press Ctrl+C to stop.

**Manual sync:**
```bash
# Copy from Linux to macOS
./copy-to-macos.sh

# Copy from macOS to Linux
./copy-from-macos.sh
```

### Shared Folders

Mount macOS Desktop on Linux:

```bash
./mount-macos-folder.sh
```

Files will be accessible at `~/macos-files/`

To unmount:
```bash
fusermount -u ~/macos-files
```

## Project Structure

```
Testonmac/
├── OSX-KVM/                      # OSX-KVM repository
│   ├── start-macos.sh           # Main VM startup script (optimized)
│   ├── OpenCore/                # OpenCore bootloader files
│   ├── mac_hdd_ng.img          # macOS virtual disk (created during setup)
│   └── BaseSystem.img          # macOS installer image
├── clipboard-sync-daemon.sh     # Auto clipboard sync daemon
├── copy-to-macos.sh            # Manual copy to macOS
├── copy-from-macos.sh          # Manual copy from macOS
├── mount-macos-folder.sh       # SSHFS mount script
├── shared/                      # Shared folder directory
├── plan/                        # Project planning and activity logs
│   └── ACTIVITIES.md           # Development activity log
├── SETUP-GUIDE.md              # Original setup documentation
├── README.md                   # This file
└── .gitignore                  # Git ignore rules
```

## VM Configuration

### Current Specifications

- **RAM**: 12GB
- **CPU**: 8 cores / 16 threads (host passthrough)
- **Graphics**: VGA with 256MB VRAM
- **Disk**: 256GB qcow2 image
- **Network**: User-mode networking with SSH port forwarding (2222 → 22)
- **Boot**: OpenCore bootloader

### Modifying VM Resources

Edit `OSX-KVM/start-macos.sh` and change these variables:

```bash
ALLOCATED_RAM="12288"  # RAM in MB (12GB = 12288)
CPU_CORES="8"          # Number of CPU cores
CPU_THREADS="16"       # Number of CPU threads
```

## Troubleshooting

### SSH Connection Asks for Password

Ensure:
1. SSH key is in `~/.ssh/authorized_keys` on macOS (not `autorized_keys` - check spelling!)
2. Permissions are correct: `chmod 600 ~/.ssh/authorized_keys`
3. SSH config in `~/.ssh/config` points to correct key and username

### VM Won't Boot

1. Check KVM modules are loaded: `lsmod | grep kvm`
2. Verify you're in the kvm group: `groups | grep kvm`
3. Check QEMU errors in terminal output

### Clipboard Sync Not Working

1. Ensure SSH is working: `ssh -p 2222 YOUR_USERNAME@localhost whoami`
2. Check `xclip` is installed: `which xclip`
3. Verify macOS has `pbcopy` and `pbpaste` (built-in on macOS)

### Shared Folder Mount Fails

1. Ensure SSHFS is installed: `which sshfs`
2. Check SSH connection works without password
3. Verify the macOS path exists: `ssh -p 2222 localhost "ls ~/Desktop"`

## Performance Tips

1. **Use host CPU passthrough** for better performance (already configured)
2. **Allocate more RAM** if available (12GB is a good balance)
3. **Use SSD storage** for the virtual disk for faster I/O
4. **Close unnecessary applications** on the host when running VM
5. **Enable nested virtualization** if running iOS simulator

## Use Cases

### Flutter Development with iOS Simulator

1. Install Xcode Command Line Tools in macOS:
   ```bash
   xcode-select --install
   ```

2. Install Xcode from App Store (requires macOS 15.6+ for latest version)

3. Set up Flutter in macOS:
   ```bash
   # In macOS Terminal
   brew install flutter
   flutter doctor
   ```

4. Use SSHFS to sync project files between Linux and macOS

5. Run iOS simulator in macOS while developing on Linux

## Credits

- **OSX-KVM**: https://github.com/kholia/OSX-KVM
- **OpenCore**: https://github.com/acidanthera/OpenCorePkg
- Inspiration from the Hackintosh community

## License

This project configuration is provided as-is. Please respect Apple's EULA when using macOS.

## Contributing

Feel free to submit issues or pull requests for improvements!

## Changelog

See [ACTIVITIES.md](plan/ACTIVITIES.md) for detailed development history.
