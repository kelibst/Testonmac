#!/bin/bash

echo "================================================"
echo "SSH Key Setup for macOS VM"
echo "================================================"
echo ""
echo "Your SSH public key:"
echo "-------------------------------------------"
cat ~/.ssh/macos_vm.pub
echo "-------------------------------------------"
echo ""
echo "Please follow these steps:"
echo ""
echo "1. Open Terminal in your macOS VM"
echo ""
echo "2. Run this ONE command (copy everything):"
echo ""
echo "mkdir -p ~/.ssh && chmod 700 ~/.ssh && echo 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGgkWv4C+ptynYMSjaUlQoeki5+QVkfIch0HtatEef/M deepin-to-macos-vm' >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys && echo 'SSH key installed!'"
echo ""
echo "3. After running the command in macOS, press Enter here to test..."
read -p ""

echo ""
echo "Testing passwordless connection..."
ssh -i ~/.ssh/macos_vm -p 2222 kelibst@localhost "echo '✅ Success! Passwordless SSH is working!'"

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Perfect! Now updating clipboard scripts..."
else
    echo ""
    echo "❌ Still not working. Let me check what user you're using in macOS..."
    echo "Please run this in macOS Terminal and tell me the output:"
    echo "   whoami"
fi
