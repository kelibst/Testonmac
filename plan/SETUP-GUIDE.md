# macOS VM Complete Setup Guide

## 🚀 Quick Start

### 1. Start the macOS VM
```bash
./start-macos.sh
```
Or double-click "Start-macOS-VM" on your desktop.

---

## 📁 Shared Folder Setup

### On Deepin Host:
The shared folder is located at:
```
/home/kelib/Desktop/projects/Testonmac/shared/
```

Any files you put here will be accessible from macOS!

### In macOS VM (One-Time Setup):

**Transfer the mount script to macOS:**
```bash
# On Deepin host:
scp -P 2222 mount-shared-folder-macos.sh username@localhost:~/
```

**In macOS Terminal:**
```bash
chmod +x ~/mount-shared-folder-macos.sh
./mount-shared-folder-macos.sh
```

The shared folder will be mounted at `/Volumes/SharedFolder/`

**To auto-mount on startup**, add this to your macOS `~/.zshrc`:
```bash
if [ ! -d "/Volumes/SharedFolder" ] || ! mount | grep -q "/Volumes/SharedFolder"; then
    sudo mount_9p sharedfolder /Volumes/SharedFolder 2>/dev/null
fi
```

---

## 📋 Clipboard Sharing

### Option 1: Auto-Sync Daemon (Recommended)

**Start the clipboard daemon on Deepin:**
```bash
cd ~/Desktop/projects/Testonmac
./clipboard-sync-daemon.sh &
```

This will automatically sync your clipboard every 2 seconds!
- Copy on Deepin → Automatically appears in macOS
- Copy on macOS → Automatically appears in Deepin

**Stop the daemon:**
```bash
pkill -f clipboard-sync-daemon
```

### Option 2: Manual Sync Scripts

**Copy from Deepin to macOS:**
```bash
./copy-to-macos.sh
```

**Copy from macOS to Deepin:**
```bash
./copy-from-macos.sh
```

---

## ⌨️ Keyboard Shortcuts (Optional)

You can set up keyboard shortcuts in Deepin Settings:

1. **Settings** → **Keyboard** → **Shortcuts** → **Custom Shortcuts**
2. Add shortcuts:
   - **Ctrl+Shift+C**: `/home/kelib/Desktop/projects/Testonmac/copy-to-macos.sh`
   - **Ctrl+Shift+V**: `/home/kelib/Desktop/projects/Testonmac/copy-from-macos.sh`

---

## 🔧 Troubleshooting

### Shared Folder Not Mounting
1. Make sure VM was started with `./start-macos.sh`
2. Check if 9p module is loaded: `sudo kextstat | grep 9p`
3. Try manual mount: `sudo mount_9p sharedfolder /Volumes/SharedFolder`

### Clipboard Not Working
1. Ensure SSH is enabled in macOS (System Settings → Sharing → Remote Login)
2. Test SSH connection: `ssh -p 2222 localhost`
3. Check if daemon is running: `ps aux | grep clipboard-sync`

### VM Performance Issues
- Allocated RAM: 12GB
- CPU: 8 cores / 16 threads
- If still slow, reduce transparency in macOS:
  ```bash
  defaults write com.apple.universalaccess reduceTransparency -bool true
  ```

---

## 📊 Current Configuration

- **Host**: Deepin Linux
- **Guest**: macOS Sonoma
- **RAM**: 12GB
- **CPU**: 8 cores / 16 threads (host passthrough)
- **Graphics**: VGA with 256MB VRAM
- **Network**: User-mode with SSH on port 2222
- **Shared Folder**: 9p/virtfs at `/Volumes/SharedFolder`
- **Clipboard**: SSH-based with auto-sync daemon

---

## 🎯 Quick Reference

| Task | Command/Location |
|------|------------------|
| Start VM | `./start-macos.sh` or desktop icon |
| Shared folder (Deepin) | `/home/kelib/Desktop/projects/Testonmac/shared/` |
| Shared folder (macOS) | `/Volumes/SharedFolder/` |
| Mount shared folder | `./mount-shared-folder-macos.sh` (in macOS) |
| Start clipboard sync | `./clipboard-sync-daemon.sh &` |
| Copy to macOS | `./copy-to-macos.sh` |
| Copy from macOS | `./copy-from-macos.sh` |
| SSH to macOS | `ssh -p 2222 username@localhost` |

---

## 📝 Notes

- The shared folder uses 9p filesystem (native QEMU support)
- Clipboard sync requires Remote Login enabled in macOS
- First SSH connection will ask you to accept the host key
- Files in shared folder are instantly accessible from both systems
- Auto-sync daemon runs in background until stopped
