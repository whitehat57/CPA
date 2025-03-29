#!/bin/bash

# CyberPeopleAttack Online Installer
clear
echo "====================================="
echo "   CyberPeopleAttack Installer v2025  "
echo "====================================="
echo "      _   _   _   _   _   _           "
echo "     / \ / \ / \ / \ / \ / \         "
echo "    ( C | P | A | I | N | S )          "
echo "     \_/ \_/ \_/ \_/ \_/ \_/         "
echo "====================================="

echo "[+] Initializing online installer..."

INSTALLER_URL="https://raw.githubusercontent.com/whitehat57/CPA/main/installer.sh"

# Check dependencies
for cmd in curl bash; do
  if ! command -v $cmd &>/dev/null; then
    echo "[-] $cmd not found. Please install it first."
    exit 1
  fi
done

# Use home directory instead of /tmp
TMP_SCRIPT="$HOME/.cpa_installer.sh"
echo "[+] Downloading installer from: $INSTALLER_URL"
curl -fsSL "$INSTALLER_URL" -o "$TMP_SCRIPT"

if [ $? -ne 0 ]; then
  echo "[-] Failed to download the installer."
  exit 1
fi

chmod +x "$TMP_SCRIPT"
echo "[+] Running the installer..."
bash "$TMP_SCRIPT"

# Clean up
rm "$TMP_SCRIPT"
echo "[+] Installer complete."
echo "[!] Please restart Termux or run 'source ~/.bashrc'"
