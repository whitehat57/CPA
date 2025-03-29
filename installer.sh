#!/bin/bash

# CyberPeopleAttack Installer v2025
clear
cat << 'EOF'
=====================================
   CyberPeopleAttack Installer v2025
=====================================
      _   _   _   _   _   _         
     / \ / \ / \ / \ / \ / \       
    ( C | P | A | I | N | S )       
     \_/ \_/ \_/ \_/ \_/ \_/       
=====================================
EOF

echo "[+] Starting full installer script..."

# Update and install essential packages
echo "[+] Updating package lists..."
pkg update -y && pkg upgrade -y

# Install core languages and tools
echo "[+] Installing Python, Go, Node.js, and pipx..."
pkg install -y python golang nodejs curl git zsh
python -m ensurepip
python -m pip install --upgrade pip
python -m pip install pipx
pipx ensurepath

# Set Go path properly
mkdir -p ~/go/{bin,src,pkg}
echo 'export GOPATH=$HOME/go' >> ~/.profile
echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.profile

# Install required Python libraries
echo "[+] Installing Python libraries..."
pip install aiohttp==3.11.14 colorama==0.4.6 fake_useragent==2.1.0 requests==2.32.3 urllib3==2.3.0

# Install required Node.js libraries
echo "[+] Installing Node.js libraries..."
npm install -g net http2 tls cluster url crypto user-agents fs header-generator fake-useragent https-proxy-agent

# Clone required repositories
echo "[+] Cloning project repositories..."
git clone https://github.com/whitehat57/LOIC.git
cd LOIC
chmod +x LOIC
cd
git clone https://gitlab.com/whitehat57/cpa.git
cd cpa
go mod download
go get github.com/fatih/color@v1.15.0
go build main.go
cd
git clone https://gitlab.com/whitehat57/karma-go.git
cd karma-go
go mod download
go mod download golang.org/x/net github.com/fatih/color
go get golang.org/x/net/idna@v0.21.0 github.com/fatih/color@v1.16.0
go build -o karma *.go
cd
git clone https://gitlab.com/whitehat57/techstack.git
cd techstack
pkg install python clang openssl libffi
pip install requests builtwith python-whois colorama
pip install dnspython
cd
# Set hacker-style font for Termux
echo "[+] Setting hacker-style font for Termux..."
mkdir -p ~/.termux
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
curl -fsSL -o ~/.termux/font.ttf "$FONT_URL"
echo "font_size=14" > ~/.termux/termux.properties
termux-reload-settings

# Install Oh My Zsh and plugins
echo "[+] Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

ZSH_CUSTOM=~/.oh-my-zsh/custom

echo "[+] Installing Zsh plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions

# Set Zsh as default shell and configure prompt
echo "[+] Setting custom Zsh prompt..."
sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc
echo 'export PROMPT="%F{green}Termux💖CPA%f %1~ %# "' >> ~/.zshrc
# Tambahkan ASCII banner CPA ke ~/.zshrc
echo '
# CPA Banner
echo -e "
\033[1;31m█▀▀█\033[0m      \033[1;90m█▀▀▀▀█\033[0m \033[1;37m█▀▀▀▀█\033[0m \033[1;32m█▀▀▀▀█\033[0m
\033[1;31m█──█\033[0m      \033[1;90m█────█\033[0m \033[1;37m█────█\033[0m \033[1;32m█────█\033[0m
\033[1;31m█▄▄█\033[0m      \033[1;90m█▄▄▄▄█\033[0m \033[1;37m█▄▄▄▄█\033[0m \033[1;32m█▄▄▄▄█\033[0m

       \033[1;33m×× CYBER PEOPLE ATTACK ××\033[0m
"
' >> ~/.zshrc

chsh -s zsh

# Done
echo "[+] Installation complete. Please restart Termux or run 'source ~/.zshrc'"
echo "[!] Enjoy CyberPeopleAttack Mini Distro! ⚔️"
