# Recommended iOS Testing Workflow

## Current Working Setup

Your macOS VM is fully functional for iOS app testing with the following configuration:

**What Works:**
- ✅ macOS Sonoma 14.8.2 VM
- ✅ Xcode 15.4 with iOS 17.5 Simulator
- ✅ Flutter 3.35.7
- ✅ SSH access (passwordless)
- ✅ VNC port forwarding configured
- ✅ Project transferred and ready

**Performance:**
- iOS Simulator runs on CPU (software rendering)
- Acceptable for testing and development
- Not as fast as physical Mac, but functional

---

## Recommended Workflow: VNC + SSH

This gives you the best balance of performance and usability.

### Setup VNC (One-Time)

**1. Restart VM with VNC port forwarding (already configured):**
```bash
cd /home/kelib/Desktop/projects/Testonmac/OSX-KVM
./start-macos-optimized.sh
```

**2. Enable VNC in macOS:**
```bash
ssh -p 2222 kelibst@localhost
chmod +x ~/enable-vnc-macos.sh
./enable-vnc-macos.sh
# Set a VNC password when prompted
```

**3. Install VNC viewer on Linux:**
```bash
sudo apt install remmina
# OR
sudo apt install tigervnc-viewer
```

---

## Daily Development Workflow

### Start Your Session

**Terminal 1 - SSH to macOS:**
```bash
ssh -p 2222 kelibst@localhost
cd ~/Developer/Projects/reshscore_mobile_flutter
```

**Terminal 2 - Start Simulator:**
```bash
ssh -p 2222 kelibst@localhost "open -a Simulator"
```

**Terminal 1 - Run Flutter App:**
```bash
source ~/.zshrc
flutter run
```

### View Simulator (When Needed)

**Only open VNC when you need to SEE the app:**
```bash
vncviewer localhost:5900
# OR
remmina
# Connect to localhost:5900
```

### Hot Reload

**In Terminal 1 (no VNC needed):**
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

**Close VNC when done visual testing - app keeps running!**

---

## Performance Tips

1. **Work 90% in terminal, 10% in VNC**
   - Use SSH for all Flutter commands
   - Use VNC only for visual inspection
   - This minimizes rendering overhead

2. **Close unused macOS apps**
   - Keep only Simulator and Terminal open
   - Close Safari, Finder windows, etc.

3. **Use Flutter release mode for performance testing**
   ```bash
   flutter run --release
   ```

4. **Monitor host resources**
   ```bash
   # On Linux
   free -h  # Keep swap usage low
   htop     # Monitor CPU
   ```

---

## Handling the Facebook Auth Issue

The app has a Swift version incompatibility with flutter_facebook_auth.

**Quick Fix:**

Edit `pubspec.yaml`:
```yaml
dependencies:
  # flutter_facebook_auth: ^7.1.1  # Temporarily disabled for iOS
```

Then:
```bash
flutter pub get
flutter clean
flutter run
```

This disables Facebook login on iOS only, everything else works.

---

## File Locations

**On macOS VM:**
- Project: `~/Developer/Projects/reshscore_mobile_flutter/`
- Flutter: `~/Developer/flutter/`

**On Linux:**
- Project: `~/Desktop/projects/reshscore_mobile_flutter/`
- VM scripts: `~/Desktop/projects/Testonmac/OSX-KVM/`

**Transfer files:**
```bash
# Linux to macOS
rsync -avz --progress -e "ssh -p 2222" \
  ~/Desktop/projects/reshscore_mobile_flutter/ \
  kelibst@localhost:~/Developer/Projects/reshscore_mobile_flutter/ \
  --exclude='.git' --exclude='build'
```

---

## Troubleshooting

### Simulator not detected

```bash
# Boot simulator first
ssh -p 2222 kelibst@localhost "open -a Simulator"

# Wait 10 seconds, then check
ssh -p 2222 kelibst@localhost "source ~/.zshrc && flutter devices"
```

### VNC won't connect

```bash
# Check if Screen Sharing is running
ssh -p 2222 kelibst@localhost "launchctl list | grep screensharing"

# Restart it
ssh -p 2222 kelibst@localhost "sudo /System/Library/CoreServices/RemoteManagement/ARDAgent.app/Contents/Resources/kickstart -restart -agent"
```

### Flutter command not found

```bash
# Always source ~/.zshrc first
ssh -p 2222 kelibst@localhost "source ~/.zshrc && flutter doctor"
```

---

## What NOT to Do

❌ **Don't attempt GPU passthrough** - It doesn't work reliably with macOS VMs
❌ **Don't expect native Mac performance** - This is a VM, slower is normal
❌ **Don't keep VNC open all the time** - Use SSH instead for better performance
❌ **Don't run multiple simulators** - Stick to one at a time

---

## Summary

**Your current setup is good for:**
- ✅ iOS app functional testing
- ✅ UI/UX testing (via VNC when needed)
- ✅ Flutter development and hot reload
- ✅ Build verification

**Not ideal for:**
- ⚠️ Performance benchmarking (use real device)
- ⚠️ Graphics-intensive apps (VM limitation)
- ⚠️ Production app store builds (use real Mac or CI/CD)

**For your use case (testing reshscore_mobile_flutter), this setup is perfectly adequate.**

---

## Quick Reference

```bash
# Start VM
cd ~/Desktop/projects/Testonmac/OSX-KVM
./start-macos-optimized.sh

# SSH into macOS
ssh -p 2222 kelibst@localhost

# Start Simulator
open -a Simulator

# Run app
cd ~/Developer/Projects/reshscore_mobile_flutter
flutter run

# View Simulator (optional)
vncviewer localhost:5900
```

---

**For complete details, see:**
- [FLUTTER-iOS-TESTING-GUIDE.md](FLUTTER-iOS-TESTING-GUIDE.md) - Complete testing guide
- [VNC-SETUP-INSTRUCTIONS.md](VNC-SETUP-INSTRUCTIONS.md) - VNC setup details
- [HEADLESS-SIMULATOR-PLAN.md](HEADLESS-SIMULATOR-PLAN.md) - Performance optimization ideas
