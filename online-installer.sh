sekarang apakah script ini butuh di update biar sesuai dengan script yang udah kita bikin ? :
#!/bin/bash

# CyberPeopleAttack Online Installer
clear
echo "====================================="
echo "   CyberPeopleAttack Installer v2025  "
echo "====================================="
echo "      _   _   _   _   _   _           "
echo "     / \ / \ / \ / \ / \ / \         "
echo "    ( C | P | A | I | N | S )        "
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

# Use home directory for temporary files
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

# Set hacker-style font for Termux (direkt download .ttf)
echo "[+] Setting hacker-style font for Termux..."
mkdir -p ~/.termux
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
echo "[+] Downloading font from: $FONT_URL"
curl -fsSL -o ~/.termux/font.ttf "$FONT_URL"

if [ $? -ne 0 ]; then
  echo "[-] Font installation failed! Continuing..."
else
  # Set font size
  echo "font_size=14" > ~/.termux/termux.properties
  termux-reload-settings
  echo "[+] Font successfully set to Hack Nerd Font with size 14."
fi

# Clean up
rm "$TMP_SCRIPT" 2>/dev/null
echo "[+] Installer complete."
echo "[!] Please restart Termux or run 'termux-reload-settings'"
