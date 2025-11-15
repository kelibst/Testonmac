# Flutter iOS Testing Plan for macOS VM

Complete plan to test your Flutter app on iOS simulator running in the macOS VM.

## Overview

**Goal**: Run and test your Flutter app (`reshscore_mobile_flutter`) on iOS simulator within the macOS Sonoma VM.

**Current Setup:**
- ✅ Flutter 3.35.5 installed on Linux host (Deepin)
- ✅ macOS Sonoma VM running with QEMU/KVM
- ✅ Passwordless SSH access to macOS VM
- ✅ Clipboard sync working
- ✅ SSHFS for file sharing

## Implementation Plan

### Phase 1: macOS Development Environment Setup

#### Step 1.1: Install Xcode Command Line Tools
**Why**: Required for iOS development tools (simulators, build tools)
**Command** (in macOS Terminal):
```bash
xcode-select --install
```

**Time**: ~5-10 minutes
**Size**: ~1.5GB download

**Verification**:
```bash
xcode-select -p
# Should output: /Library/Developer/CommandLineTools
```

#### Step 1.2: Install Homebrew (Package Manager)
**Why**: Easiest way to install Flutter and dependencies on macOS
**Command** (in macOS Terminal):
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Time**: ~5 minutes

#### Step 1.3: Install Flutter via Homebrew
**Command** (in macOS Terminal):
```bash
brew install flutter
```

**Time**: ~10-15 minutes
**Size**: ~500MB

**Alternative Manual Installation**:
```bash
cd ~/Developer
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$HOME/Developer/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### Step 1.4: Configure Flutter for iOS Development
**Command** (in macOS Terminal):
```bash
flutter doctor
```

This will show what's missing. Then:
```bash
# Accept iOS licenses
flutter doctor --android-licenses  # (skip if Android not needed)

# Install iOS dependencies
sudo gem install cocoapods
```

### Phase 2: Project Transfer and Setup

#### Step 2.1: Mount Shared Folder
**On Linux Host**:
```bash
cd ~/Desktop/projects/Testonmac
./mount-macos-folder.sh
```

This mounts macOS Desktop at `~/macos-files/`

#### Step 2.2: Create Development Directory in macOS
**In macOS Terminal**:
```bash
mkdir -p ~/Developer/Projects
```

#### Step 2.3: Transfer Project via SSHFS
**Option A: Direct SSHFS Access** (Recommended)
```bash
# On Linux, mount macOS Developer folder
mkdir -p ~/macos-dev
sshfs -p 2222 kelibst@localhost:/Users/kelibst/Developer/Projects ~/macos-dev

# Copy project
cp -r ~/Desktop/projects/reshscore_mobile_flutter ~/macos-dev/
```

**Option B: Use rsync for Faster Transfer**
```bash
# From Linux host
rsync -avz -e "ssh -p 2222" ~/Desktop/projects/reshscore_mobile_flutter/ kelibst@localhost:~/Developer/Projects/reshscore_mobile_flutter/
```

**Option C: Git Clone** (if project is on GitHub)
```bash
# In macOS Terminal
cd ~/Developer/Projects
git clone YOUR_REPO_URL
```

### Phase 3: Flutter Project Configuration

#### Step 3.1: Install Project Dependencies
**In macOS Terminal**:
```bash
cd ~/Developer/Projects/reshscore_mobile_flutter
flutter pub get
```

#### Step 3.2: Install iOS Pods
**In macOS Terminal**:
```bash
cd ios
pod install
cd ..
```

#### Step 3.3: Run Flutter Doctor
```bash
flutter doctor -v
```

Check that iOS toolchain shows as ready.

### Phase 4: iOS Simulator Setup

#### Step 4.1: List Available Simulators
**In macOS Terminal**:
```bash
xcrun simctl list devices
```

#### Step 4.2: Create New Simulator (if needed)
```bash
# Create iPhone 15 Pro simulator
xcrun simctl create "iPhone 15 Pro" "iPhone 15 Pro" "iOS17.0"
```

#### Step 4.3: Boot Simulator
```bash
# Open simulator app
open -a Simulator

# Or boot specific device
xcrun simctl boot "iPhone 15 Pro"
```

### Phase 5: Run Flutter App on iOS

#### Step 5.1: Check Connected Devices
**In macOS Terminal**:
```bash
flutter devices
```

Should show iOS simulators.

#### Step 5.2: Run App
```bash
cd ~/Developer/Projects/reshscore_mobile_flutter
flutter run -d ios
```

Or specify exact device:
```bash
flutter run -d "iPhone 15 Pro"
```

#### Step 5.3: Hot Reload Testing
While app is running:
- Press `r` for hot reload
- Press `R` for hot restart
- Press `q` to quit

### Phase 6: Development Workflow Options

#### Option A: Develop on Linux, Build on macOS
**Workflow**:
1. Edit code on Linux (your primary environment)
2. Use SSHFS to sync files to macOS automatically
3. Run `flutter run` in macOS Terminal
4. Hot reload reflects changes instantly

**Setup**:
```bash
# Keep SSHFS mounted
sshfs -p 2222 -o follow_symlinks kelibst@localhost:~/Developer/Projects/reshscore_mobile_flutter ~/macos-dev/reshscore_mobile_flutter
```

Edit files on Linux at `~/macos-dev/reshscore_mobile_flutter/`, changes appear in macOS instantly.

#### Option B: Develop Entirely on macOS
**Workflow**:
1. SSH into macOS: `ssh -p 2222 kelibst@localhost`
2. Use `nano`, `vim`, or VS Code server for editing
3. Run Flutter commands directly

#### Option C: VS Code Remote SSH
**Workflow**:
1. Install "Remote - SSH" extension in VS Code on Linux
2. Connect to macOS VM via SSH (port 2222)
3. Edit and run Flutter commands through VS Code
4. Full IDE experience on macOS from Linux

**VS Code SSH Config** (add to `~/.ssh/config`):
```
Host macos-vm
    HostName localhost
    Port 2222
    User kelibst
    IdentityFile ~/.ssh/macos_vm
```

Then in VS Code: `Ctrl+Shift+P` > "Remote-SSH: Connect to Host" > "macos-vm"

## Performance Considerations

### Expected Performance
- **VM Resources**: 12GB RAM, 8 cores
- **iOS Simulator**: Should run smoothly with this allocation
- **Hot Reload**: Should be fast (< 2 seconds)
- **Full Build**: First build 2-5 minutes, subsequent builds faster

### Optimization Tips
1. **Increase VM RAM if needed**: Edit `start-macos.sh`, increase `ALLOCATED_RAM`
2. **Use Release Mode for Performance Testing**:
   ```bash
   flutter run --release -d ios
   ```
3. **Disable animations during testing**:
   ```bash
   # In simulator: Settings > Accessibility > Motion > Reduce Motion
   ```

## Troubleshooting

### Issue: "No devices found"
**Solution**:
```bash
# Restart simulator
killall Simulator
open -a Simulator
flutter devices
```

### Issue: "CocoaPods not installed"
**Solution**:
```bash
sudo gem install cocoapods
cd ios && pod install
```

### Issue: "Xcode license not accepted"
**Solution**:
```bash
sudo xcodebuild -license accept
```

### Issue: Slow build times
**Solutions**:
- Close other apps in macOS VM
- Increase VM RAM allocation
- Use `flutter run --debug` (faster than release for development)
- Enable `flutter run --hot` for hot reload only

### Issue: Network not working in simulator
**Solution**:
- VM has user-mode networking, simulator should have internet
- Check macOS network settings
- Restart VM if network issues persist

## Testing Checklist

After setup, verify:
- [ ] Xcode Command Line Tools installed
- [ ] Flutter installed and in PATH
- [ ] `flutter doctor` shows iOS toolchain ready
- [ ] iOS simulator launches
- [ ] `flutter devices` shows simulator
- [ ] Project dependencies installed (`flutter pub get`)
- [ ] iOS pods installed (`pod install`)
- [ ] App runs on simulator (`flutter run`)
- [ ] Hot reload works (press `r` after code change)
- [ ] App features work as expected
- [ ] Performance is acceptable

## Next Steps After Testing

1. **Build Release IPA** (for TestFlight/App Store):
   ```bash
   flutter build ios --release
   ```

2. **Run on Physical Device** (requires Apple Developer account):
   - Would need USB passthrough to VM (complex)
   - Alternative: Use Codemagic/Bitrise CI for real device testing

3. **Continuous Integration**:
   - Set up GitHub Actions with macOS runner
   - Automate iOS builds on every commit

## Estimated Timeline

- **Initial Setup**: 30-45 minutes
  - Xcode Command Line Tools: 10 minutes
  - Homebrew + Flutter: 15 minutes
  - Project transfer: 5 minutes
  - Dependencies: 10 minutes

- **First Build**: 5-10 minutes
- **Subsequent Runs**: 1-2 minutes with hot reload

## Resources

- Flutter iOS Setup: https://docs.flutter.dev/get-started/install/macos
- iOS Simulator Guide: https://developer.apple.com/documentation/xcode/running-your-app-in-simulator-or-on-a-device
- Flutter Hot Reload: https://docs.flutter.dev/tools/hot-reload

---

**Ready to Start?**

Run through Phase 1 first (macOS setup), then we'll tackle project transfer and testing!
