# Flutter iOS Testing on macOS VM - Complete Engineer Guide

## Overview

This document provides step-by-step instructions for testing the `reshscore_mobile_flutter` app on iOS Simulator running in a macOS Sonoma VM on Linux.

**Current Status:**
- ✅ macOS Sonoma 14.8.2 VM fully configured
- ✅ Xcode 15.4 installed with iOS 17.5 Simulator
- ✅ Flutter 3.35.7 ready
- ✅ SSH access configured (passwordless)
- ✅ Project transferred and dependencies installed
- ⚠️ Facebook auth temporarily disabled (Swift version incompatibility)

---

## Quick Start

### 1. Start the macOS VM

On the Linux host machine:

```bash
cd /home/kelib/Desktop/projects/Testonmac/OSX-KVM
./start-macos-optimized.sh
```

Wait for the VM to boot completely (you'll see the macOS desktop in the QEMU window).

---

### 2. SSH into macOS VM

From any terminal on the Linux host:

```bash
ssh -p 2222 kelibst@localhost
```

**Connection Details:**
- **Host:** localhost
- **Port:** 2222
- **Username:** kelibst
- **Authentication:** SSH key (passwordless, already configured)

**Verify connection:**
```bash
ssh -p 2222 kelibst@localhost "sw_vers"
```

Expected output:
```
ProductName:		macOS
ProductVersion:		14.8.2
BuildVersion:		23J126
```

---

## Testing the Flutter App

### Step 1: SSH into the VM

```bash
ssh -p 2222 kelibst@localhost
```

### Step 2: Navigate to Project Directory

```bash
cd ~/Developer/Projects/reshscore_mobile_flutter
```

### Step 3: Open iOS Simulator

```bash
open -a Simulator
```

Wait 10-15 seconds for the simulator to fully boot. You'll see an iPhone simulator window appear.

### Step 4: Verify Flutter Can See the Simulator

```bash
source ~/.zshrc
flutter devices
```

Expected output:
```
Found 2 connected devices:
  iPhone 15 Pro Max (mobile) • 319A8184-E850-4454-AC30-B701E7AB6FA4 • ios        • iOS 17.5 (simulator)
  macOS (desktop)            • macos                                • darwin-x64 • macOS 14.8.2
```

### Step 5: Run the App

**Option A - Let Flutter choose the device:**
```bash
flutter run
```

**Option B - Specify iPhone 15 Pro Max:**
```bash
flutter run -d 319A8184-E850-4454-AC30-B701E7AB6FA4
```

**Option C - Specify any available device:**
```bash
# List all available simulators first
xcrun simctl list devices available | grep iPhone

# Run on specific device by ID
flutter run -d <DEVICE_ID>
```

---

## Known Issue: Facebook Authentication

### Problem
The `flutter_facebook_auth` package (v7.1.2) requires Swift 6.1.2, but Xcode 15.4 only supports Swift 5.10.

### Current Workaround
Facebook authentication is temporarily disabled for iOS testing.

### Solution Options

**Option 1: Comment out Facebook auth in pubspec.yaml (Quick fix)**

Edit `pubspec.yaml`:
```yaml
dependencies:
  # flutter_facebook_auth: ^7.1.1  # Temporarily disabled for iOS
```

Then run:
```bash
flutter pub get
flutter clean
flutter run
```

**Option 2: Downgrade to Swift 5.10 compatible version**

Edit `pubspec.yaml`:
```yaml
dependencies:
  flutter_facebook_auth: ^6.0.0  # Compatible with Swift 5.10
```

Then run:
```bash
flutter pub get
cd ios
pod install
cd ..
flutter run
```

**Option 3: Conditional compilation (Best for production)**

Keep Facebook auth on Android, disable on iOS:
```dart
// In your code
import 'dart:io' show Platform;

void initFacebookAuth() {
  if (Platform.isAndroid) {
    // Initialize Facebook auth
  } else {
    // Skip Facebook auth on iOS
    print('Facebook auth disabled on iOS');
  }
}
```

---

## File Transfer Between Linux and macOS

### Transfer Files TO macOS VM

From Linux host:
```bash
# Single file
scp -P 2222 /path/to/file.txt kelibst@localhost:~/Desktop/

# Entire directory
rsync -avz --progress -e "ssh -p 2222" \
  /local/directory/ \
  kelibst@localhost:~/Desktop/destination/
```

### Transfer Files FROM macOS VM

From Linux host:
```bash
# Single file
scp -P 2222 kelibst@localhost:~/Desktop/file.txt /local/destination/

# Entire directory
rsync -avz --progress -e "ssh -p 2222" \
  kelibst@localhost:~/Desktop/source/ \
  /local/destination/
```

### Shared Folder (Alternative)

The VM has a shared folder configured at `/Volumes/SharedFolder/` (if mounted).

To mount in macOS:
```bash
sudo mkdir -p /Volumes/SharedFolder
sudo mount_9p sharedfolder /Volumes/SharedFolder
```

Linux location: `/home/kelib/Desktop/projects/Testonmac/shared/`

---

## Development Workflow

### Edit Code on Linux, Test on macOS

1. **Edit code on Linux** using your preferred IDE
2. **Transfer changes to macOS:**
   ```bash
   rsync -avz --progress -e "ssh -p 2222" \
     ~/Desktop/projects/reshscore_mobile_flutter/ \
     kelibst@localhost:~/Developer/Projects/reshscore_mobile_flutter/ \
     --exclude='.git' --exclude='build' --exclude='.dart_tool'
   ```
3. **Hot reload in macOS:**
   - Press `r` in the terminal where `flutter run` is active
   - Or press `R` for hot restart

### Remote Development with VS Code

1. Install "Remote - SSH" extension in VS Code
2. Add SSH config on Linux (`~/.ssh/config`):
   ```
   Host macos-vm
       HostName localhost
       Port 2222
       User kelibst
       IdentityFile ~/.ssh/macos_vm
   ```
3. Connect to `macos-vm` in VS Code
4. Open `/Users/kelibst/Developer/Projects/reshscore_mobile_flutter`
5. Develop directly in the VM

---

## Troubleshooting

### Issue: "flutter: command not found"

**Solution:**
```bash
source ~/.zshrc
# Or use full path
~/Developer/flutter/bin/flutter devices
```

### Issue: "No devices found"

**Solution:**
```bash
# Boot a simulator first
open -a Simulator

# Wait 10 seconds, then check
flutter devices
```

### Issue: iOS build fails with CocoaPods errors

**Solution:**
```bash
cd ~/Developer/Projects/reshscore_mobile_flutter/ios
rm -rf Pods Podfile.lock
pod install
cd ..
flutter clean
flutter run
```

### Issue: "xcodebuild failed with code 65"

**Solution:**
```bash
# Clean everything
flutter clean
cd ios
rm -rf build DerivedData Pods Podfile.lock
pod install
cd ..
flutter run
```

### Issue: Swift compiler errors about "BitwiseCopyable"

**Solution:** This is the Facebook SDK Swift version issue. Follow Option 1 in the "Facebook Authentication" section above to comment out the Facebook auth package.

### Issue: VM is slow or unresponsive

**Solution:**
- Check host RAM usage: `free -h`
- If swap > 2GB, reduce VM RAM allocation in `start-macos-optimized.sh`
- Current VM allocation: 6GB RAM, 8 CPU cores

### Issue: SSH connection refused

**Solution:**
```bash
# Check if VM is running
ssh -p 2222 kelibst@localhost "echo test"

# If fails, verify macOS "Remote Login" is enabled:
# System Settings > General > Sharing > Remote Login (ON)
```

---

## System Specifications

### macOS VM Configuration
- **OS:** macOS Sonoma 14.8.2
- **RAM:** 6GB
- **CPU:** 8 cores (host passthrough)
- **Disk:** 256GB QCOW2
- **Graphics:** QXL (software rendering)
- **Network:** User-mode with port forwarding

### Development Tools Installed
- **Xcode:** 15.4 (Swift 5.10)
- **Flutter:** 3.35.7 (stable)
- **Dart:** 3.9.2
- **CocoaPods:** 1.16.2
- **iOS Simulator:** 17.5

### Available iOS Simulators
- iPhone SE (3rd generation)
- iPhone 15
- iPhone 15 Plus
- iPhone 15 Pro
- iPhone 15 Pro Max
- iPad (10th generation)
- iPad Air (5th generation)
- iPad Pro (11-inch, 4th generation)
- iPad Pro (12.9-inch, 6th generation)

---

## Performance Tips

1. **Keep only one simulator running** - Close unused simulators to save RAM
2. **Use hot reload** instead of full restart when possible (press `r`)
3. **Close macOS apps** you're not using (Xcode, Safari, etc.)
4. **Monitor host RAM** - Keep swap usage below 2GB for acceptable performance
5. **Use Flutter release mode** for final testing: `flutter run --release`

---

## Useful Commands

### Flutter Commands
```bash
# Check Flutter setup
flutter doctor -v

# List all devices
flutter devices

# List all emulators
flutter emulators

# Clean build cache
flutter clean

# Rebuild everything
flutter pub get && flutter clean && flutter run

# Run in release mode (faster)
flutter run --release
```

### iOS Simulator Commands
```bash
# List all simulators
xcrun simctl list devices available

# Boot a specific simulator
xcrun simctl boot <DEVICE_ID>

# Shutdown all simulators
xcrun simctl shutdown all

# Erase simulator data (factory reset)
xcrun simctl erase all
```

### Xcode Commands
```bash
# Check Xcode version
xcodebuild -version

# List installed SDKs
xcodebuild -showsdks

# Check iOS Simulator runtimes
xcrun simctl list runtimes
```

---

## Contact & Support

- **Project location (macOS):** `~/Developer/Projects/reshscore_mobile_flutter/`
- **Project location (Linux):** `~/Desktop/projects/reshscore_mobile_flutter/`
- **VM scripts:** `/home/kelib/Desktop/projects/Testonmac/OSX-KVM/`
- **Activity log:** `/home/kelib/Desktop/projects/Testonmac/plan/ACTIVITIES.md`

For VM issues, check the project documentation:
- [README.md](README.md) - Complete VM setup guide
- [ACTIVITIES.md](plan/ACTIVITIES.md) - Development history
- [PERFORMANCE-OPTIMIZATION.md](PERFORMANCE-OPTIMIZATION.md) - VM optimization notes

---

**Last Updated:** 2025-11-08
**Status:** Ready for iOS testing (Facebook auth disabled)
