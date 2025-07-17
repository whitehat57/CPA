#!/bin/bash

# CyberPeopleAttack - One-Line Installer
# Powered by Harpy 🦅

clear
echo "=========================================="
echo "   CyberPeopleAttack Online Installer 🚀  "
echo "=========================================="

INSTALLER_URL="https://raw.githubusercontent.com/whitehat57/CPA/main/CPA-WARFARE.sh"

# Check dependencies
for cmd in curl bash; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[-] Missing: $cmd"
    echo "[!] Please install $cmd before running this installer."
    exit 1
  fi
done

echo "[+] Launching CPA-WARFARE.sh from:"
echo "    $INSTALLER_URL"
echo

# Direct stream execution
curl -fsSL "$INSTALLER_URL" | bash

if [ $? -ne 0 ]; then
  echo "[-] CPA Warfare installation failed or was interrupted."
  exit 1
fi

echo
echo "[✓] CPA Warfare fully deployed!"
echo "[→] Type 'dashboard' to open your cyber control center."
echo "[⚠] Run 'source ~/.zshrc' if banner doesn’t show after install."
echo
echo "🦅 Welcome to the grid, Operative."
