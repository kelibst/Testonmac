# Simple SSH Key Setup for macOS VM

## The Problem
SSH from Deepin to macOS keeps asking for password but can't read it properly.

## Simple Solution (Type in macOS manually)

### Step 1: Open Terminal in your macOS VM

### Step 2: Type these commands ONE BY ONE in macOS Terminal:

```bash
mkdir -p ~/.ssh
```
Press Enter, then:

```bash
chmod 700 ~/.ssh
```
Press Enter, then:

```bash
nano ~/.ssh/authorized_keys
```
Press Enter. This will open a text editor.

### Step 3: In the nano editor, type (or carefully copy from this screen):

```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgkWv4C+ptynYMSjaUlQoeki5+QVkfIch0HtatEef/M deepin-to-macos-vm
```

**Important**: This must be ONE line, no line breaks!

### Step 4: Save and exit nano:
- Press `Ctrl + O` (to save)
- Press `Enter` (to confirm filename)
- Press `Ctrl + X` (to exit)

### Step 5: Back in macOS Terminal, run:

```bash
chmod 600 ~/.ssh/authorized_keys
```

### Step 6: Verify it worked:

```bash
cat ~/.ssh/authorized_keys
```

You should see the ssh-ed25519 key.

### Step 7: Come back to Deepin and tell me you're done!

I'll then test the passwordless connection and update all the clipboard scripts.

---

## Alternative: Use a File Transfer

If typing is too error-prone, we can:
1. Save the key to the shared SSHFS folder
2. Copy it in macOS
3. Set it up

Let me know which approach you prefer!
