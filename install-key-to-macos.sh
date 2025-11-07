#!/bin/bash

echo "🔑 Installing SSH key to macOS VM..."
echo ""
echo "This will prompt for your macOS password ONCE."
echo "After this, you won't need passwords for SSH connections."
echo ""

# Read the public key
PUB_KEY=$(cat ~/.ssh/macos_vm.pub)

# SSH into macOS and set up the key
ssh -p 2222 -o StrictHostKeyChecking=no localhost << EOF
mkdir -p ~/.ssh
chmod 700 ~/.ssh
echo '$PUB_KEY' >> ~/.ssh/authorized_keys
chmod 600 ~/.ssh/authorized_keys
echo "✅ SSH key installed successfully!"
exit
EOF

echo ""
echo "Testing passwordless connection..."
ssh -p 2222 -i ~/.ssh/macos_vm -o StrictHostKeyChecking=no localhost "echo '✅ Passwordless SSH working!'"

if [ $? -eq 0 ]; then
    echo ""
    echo "🎉 Success! SSH key authentication is now set up."
else
    echo ""
    echo "❌ Something went wrong. Please check the output above."
fi
