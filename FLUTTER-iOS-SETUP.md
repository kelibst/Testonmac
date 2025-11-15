# Flutter iOS Testing Setup on macOS VM

Complete guide to set up Flutter iOS development and testing on your macOS Sonoma VM.

## Prerequisites

- ✅ macOS Sonoma VM running
- ✅ SSH access configured (port 2222)
- ✅ Passwordless SSH with ED25519 key
- ✅ At least 12GB RAM allocated to VM
- ✅ 8 cores / 16 threads

## Setup Steps

### Phase 1: macOS Development Tools (15-20 min)

#### 1.1 Install Xcode Command Line Tools
```bash
# In macOS Terminal via SSH
ssh -p 2222 kelibst@localhost

# Install Command Line Tools
xcode-select --install
```

**Wait for installation to complete** (5-10 minutes, ~1.5GB download)

Verify installation:
```bash
xcode-select -p
# Should output: /Library/Developer/CommandLineTools
```

#### 1.2 Install Homebrew
```bash
# Install Homebrew (package manager for macOS)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

Follow the post-installation instructions to add Homebrew to PATH:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

Verify:
```bash
brew --version
```

### Phase 2: Flutter SDK Installation (10-15 min)

#### 2.1 Install Flutter via Homebrew
```bash
# Install Flutter
brew install flutter

# Or download directly
cd ~/Developer
git clone https://github.com/flutter/flutter.git -b stable
echo 'export PATH="$HOME/Developer/flutter/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

#### 2.2 Run Flutter Doctor
```bash
flutter doctor -v
```

Expected output will show:
- ✅ Flutter (version 3.x.x)
- ⚠️  Xcode - not installed (we're using Command Line Tools only)
- ✅ iOS toolchain - partially ready
- ⚠️  Android toolchain - not needed for iOS testing

#### 2.3 Accept iOS Licenses
```bash
sudo xcodebuild -license accept
```

### Phase 3: iOS Development Dependencies (5-10 min)

#### 3.1 Install CocoaPods
```bash
# CocoaPods manages iOS dependencies
sudo gem install cocoapods

# Verify installation
pod --version
```

#### 3.2 Install iOS Simulators
```bash
# List available simulators
xcrun simctl list devices

# If no simulators exist, download runtime
# This requires full Xcode or separate runtime download
```

**Note**: Full Xcode requires macOS 15.6+ for latest version. For Sonoma 14.x:
- Use Xcode 15.4 from Apple Developer Portal
- Or use Command Line Tools + manual simulator setup

### Phase 4: Development Workflow Setup (5 min)

#### 4.1 Create Development Folder
```bash
# In macOS
mkdir -p ~/Developer/Projects
```

#### 4.2 Mount Shared Folder (from Linux)
```bash
# On Linux host
mkdir -p ~/flutter-ios-dev
sshfs -p 2222 kelibst@localhost:/Users/kelibst/Developer/Projects ~/flutter-ios-dev
```

Now you can:
- Edit Flutter code on Linux
- Files sync automatically to macOS
- Run/build on macOS iOS simulator

### Phase 5: Transfer Your Flutter Project

#### Option A: Via SSHFS (Recommended for Development)
```bash
# On Linux
cp -r ~/Desktop/projects/reshscore_mobile_flutter ~/flutter-ios-dev/
```

Changes sync automatically!

#### Option B: Via rsync (One-time copy)
```bash
# From Linux
rsync -avz -e "ssh -p 2222" ~/Desktop/projects/reshscore_mobile_flutter/ kelibst@localhost:~/Developer/Projects/reshscore_mobile_flutter/
```

#### Option C: Via Git
```bash
# In macOS
cd ~/Developer/Projects
git clone YOUR_REPO_URL
```

### Phase 6: Run Flutter App on iOS

#### 6.1 Navigate to Project
```bash
# In macOS (via SSH)
ssh -p 2222 kelibst@localhost
cd ~/Developer/Projects/reshscore_mobile_flutter
```

#### 6.2 Install Dependencies
```bash
# Get Flutter packages
flutter pub get

# Install iOS pods
cd ios
pod install
cd ..
```

#### 6.3 List Available Devices
```bash
flutter devices
```

Should show iOS simulators.

#### 6.4 Run the App
```bash
# Run on default iOS simulator
flutter run -d ios

# Or specify device
flutter run -d "iPhone 15 Pro"
```

### Phase 7: Development Workflow

#### Workflow A: Edit on Linux, Run on macOS
1. **Linux**: Open project in VS Code: `code ~/flutter-ios-dev/reshscore_mobile_flutter`
2. **macOS**: Keep `flutter run` active
3. **Linux**: Edit code, save
4. **macOS**: Press `r` for hot reload
5. Changes appear instantly in simulator

#### Workflow B: VS Code Remote SSH
1. **Linux**: Install "Remote - SSH" extension in VS Code
2. Connect to macOS: `Ctrl+Shift+P` > "Remote-SSH: Connect to Host" > "macos-vm"
3. Open folder: `~/Developer/Projects/reshscore_mobile_flutter`
4. Use VS Code terminal to run `flutter run`
5. Full IDE experience with debugging

#### Workflow C: Full macOS Development
1. SSH into macOS: `ssh -p 2222 kelibst@localhost`
2. Use terminal-based editor (nano, vim) or install VS Code in macOS
3. Run Flutter commands directly

## Testing Commands

### Build and Test
```bash
# Run in debug mode (faster)
flutter run -d ios --debug

# Run in release mode (performance testing)
flutter run -d ios --release

# Run tests
flutter test

# Build IPA (requires Apple Developer account)
flutter build ios --release
```

### Hot Reload
While `flutter run` is active:
- `r` - Hot reload (fast)
- `R` - Hot restart (resets state)
- `q` - Quit
- `h` - Help

### Troubleshooting

#### "No devices found"
```bash
# Start simulator manually
open -a Simulator

# Or specific device
xcrun simctl boot "iPhone 15 Pro"

# Then run flutter devices
```

#### "CocoaPods not installed"
```bash
sudo gem install cocoapods
cd ios && pod install
```

#### "Xcode license not accepted"
```bash
sudo xcodebuild -license accept
```

#### Simulator not responding
```bash
# Kill and restart
killall Simulator
open -a Simulator
```

## Performance Tips

1. **Use Debug Mode for Development**: Faster builds, hot reload
2. **Use Release Mode for Testing**: Better performance, realistic testing
3. **Close Unused Apps in macOS**: Free up RAM
4. **Use SSHFS for Live Sync**: Edit on Linux, no manual copying
5. **Keep Flutter Running**: Hot reload is faster than full restart

## Expected Performance

With your current VM setup (12GB RAM, 8 cores):
- **First build**: 2-5 minutes
- **Hot reload**: 1-2 seconds
- **Hot restart**: 5-10 seconds
- **Simulator**: Smooth at 60fps for most apps
- **Build times**: Comparable to physical Mac

## Next Steps

1. Complete setup following phases above
2. Test with a simple Flutter app first
3. Run your reshscore_mobile_flutter app
4. Iterate with hot reload
5. Build for release when ready

## Useful Resources

- Flutter iOS Setup: https://docs.flutter.dev/get-started/install/macos
- iOS Simulator Guide: https://developer.apple.com/documentation/xcode/running-your-app-in-simulator
- Flutter Hot Reload: https://docs.flutter.dev/tools/hot-reload
- CocoaPods: https://cocoapods.org

---

Ready to start? Let's begin with Phase 1!
