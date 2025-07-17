#!/bin/bash

# CPA One-Line Installer v2025 by Harpy 🦅
clear
echo "========================================="
echo " CyberPeopleAttack One-Line Installer 🚀 "
echo "========================================="

INSTALLER_URL="https://raw.githubusercontent.com/whitehat57/CPA/main/CPA-WARFARE.sh"

echo "[✓] Verifying required tools..."

for cmd in curl bash; do
  if ! command -v $cmd >/dev/null 2>&1; then
    echo "[-] Missing dependency: $cmd"
    echo "[!] Please install $cmd manually and re-run this script."
    exit 1
  fi
done

echo "[+] Fetching CPA-WARFARE.sh from:"
echo "    $INSTALLER_URL"
echo

curl -fsSL "$INSTALLER_URL" | bash

if [ $? -ne 0 ]; then
  echo "[-] Installer failed or was interrupted."
  exit 1
fi

echo
echo "[✓] CPA Warfare installation complete!"
echo "[→] Type 'dashboard' to launch your control center."
echo "[⚠] If banner doesn't show, run: source ~/.zshrc"
echo
echo "🦅 Operative, you're now live on the grid. Stay sharp!"
