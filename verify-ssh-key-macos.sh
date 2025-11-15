#!/bin/bash

echo "=== SSH Key Verification Script for macOS ==="
echo ""

echo "1. Checking if .ssh directory exists and has correct permissions:"
ls -la ~/.ssh/
echo ""

echo "2. Content of authorized_keys file:"
cat ~/.ssh/authorized_keys
echo ""

echo "3. Number of characters in authorized_keys:"
wc -c ~/.ssh/authorized_keys
echo ""

echo "4. MD5 hash of authorized_keys (for comparison):"
md5 ~/.ssh/authorized_keys
echo ""

echo "5. Fixing permissions:"
chmod 700 ~/.ssh
chmod 600 ~/.ssh/authorized_keys
echo "Permissions fixed!"
echo ""

echo "6. Verifying permissions:"
ls -la ~/.ssh/authorized_keys
echo ""

echo "Done! Now try SSH connection from Deepin."
