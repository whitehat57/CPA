#!/bin/bash

# CyberPeopleAttack Installer Script

# Banner
clear
echo "  ___  ____   __  "
echo " / __)(  _ \ / _\ "
echo "( (__  ) __//    \"
echo " \___)(__)  \_/\_/ v.2025"
echo "    Installer"
echo "=========================="

# Set variables
export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin:$HOME/.local/bin:$HOME/.cargo/bin

# Update and install essential packages
pkg update -y && pkg upgrade -y
pkg install -y git curl wget python golang nodejs clang \
    tsu proot termux-api nano unzip zip \
    libffi openssl rust binutils

# Setup pip & pipx
python -m ensurepip --upgrade
python -m pip install --upgrade pip
python -m pip install pipx
pipx ensurepath

# Install Python libraries
pipx install --pip-args="--no-cache-dir" aiohttp==3.11.14
pipx inject aiohttp colorama==0.4.6 fake_useragent==2.1.0 Requests==2.32.3 urllib3==2.3.0

# Install Node.js libraries
yarn global add net http2 tls cluster url crypto user-agents fs header-generator fake-useragent https-proxy-agent || \
npm install -g net http2 tls cluster url crypto user-agents fs header-generator fake-useragent https-proxy-agent

# Clone tools
TOOL_DIR=$HOME/CPA_TOOLS
mkdir -p "$TOOL_DIR"
cd "$TOOL_DIR"

REPOS=(
  "https://github.com/whitehat57/LOIC.git"
  "https://gitlab.com/whitehat57/cpa.git"
  "https://gitlab.com/whitehat57/karma-go.git"
  "https://gitlab.com/whitehat57/techstack.git"
)

for repo in "${REPOS[@]}"; do
  git clone "$repo"
done

# Setup Termux startup banner
BANNER_FILE="$PREFIX/etc/motd"
cat > "$BANNER_FILE" <<EOF
               ▒▒████████      ▒▒█████████      ▒▒████████
              ▒▒██     ▒▒█      ▒▒██   ▒▒██      ▒▒██  ▒▒██
             ▒▒██               ▒▒██   ▒▒██      ▒▒██  ▒▒██
             ▒▒██               ▒▒██▒█████       ▒▒████████
              ▒▒██     ▒▒█      ▒▒██             ▒▒██  ▒▒██
               ▒▒████████      ▒▒███            ▒▒███  ▒▒██  

           ---------------⚔️⚔️ CYBER PEOPLE ATTACK ⚔️⚔️---------------
EOF

# Set custom shell prompt
SHELL_RC="$HOME/.bashrc"
echo "\nexport PS1=\"\\[\\e[1;32m\\]CPA@free_Palestine > \\[$(tput sgr0)\\]\"" >> "$SHELL_RC"

# Finish
echo -e "\n[+] Installation complete!\n[!] Restart Termux or run 'source ~/.bashrc' to apply the changes."
exit 0
