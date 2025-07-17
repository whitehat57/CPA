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

# Update package lists
if [ ! -f /data/data/com.termux/files/usr/etc/apt/sources.list ]; then
  echo "[!] Termux sources not found! Skipping update."
else
  echo "[+] Updating package lists..."
  pkg update -y && pkg upgrade -y
fi

# Install essential packages
for pkg in python golang nodejs curl git zsh; do
  if ! command -v $pkg >/dev/null 2>&1; then
    echo "[+] Installing $pkg..."
    pkg install -y $pkg
  else
    echo "[✓] $pkg already installed."
  fi
done

# Ensure pip and pipx
if ! command -v pipx >/dev/null 2>&1; then
  python -m ensurepip
  python -m pip install --upgrade pip
  python -m pip install pipx
  pipx ensurepath
else
  echo "[✓] pipx already installed."
fi

# Set Go path
if ! grep -q "GOPATH" ~/.profile; then
  mkdir -p ~/go/{bin,src,pkg}
  echo 'export GOPATH=$HOME/go' >> ~/.profile
  echo 'export PATH=$PATH:$GOPATH/bin:$GOROOT/bin' >> ~/.profile
else
  echo "[✓] Go path already set."
fi

# Install Python libraries
echo "[+] Installing Python libraries..."
pip install aiohttp==3.11.14 colorama==0.4.6 fake_useragent==2.1.0 requests==2.32.3 urllib3==2.3.0

# Install Node.js libraries
echo "[+] Installing Node.js libraries..."
npm install -g net http2 tls cluster url crypto user-agents fs header-generator fake-useragent https-proxy-agent

# Clone and setup projects
declare -A repos=(
  [LOIC]="https://github.com/whitehat57/LOIC.git"
  [cpa]="https://gitlab.com/whitehat57/cpa.git"
  [karma-go]="https://gitlab.com/whitehat57/karma-go.git"
  [techstack]="https://gitlab.com/whitehat57/techstack.git"
)

for dir in "${!repos[@]}"; do
  if [ ! -d "$HOME/$dir" ]; then
    echo "[+] Cloning $dir..."
    git clone "${repos[$dir]}"
  else
    echo "[✓] $dir already cloned."
  fi

done

cd LOIC && chmod +x LOIC && cd
# Build CPA
cd ~/cpa 2>/dev/null && go mod download && go get github.com/fatih/color@v1.15.0 && go build main.go

# Build karma-go
cd ~/karma-go 2>/dev/null && go mod download && go get golang.org/x/net/idna@v0.21.0 github.com/fatih/color@v1.16.0 && go build -o karma *.go

# Setup techstack dependencies
cd ~/techstack && pkg install -y clang openssl libffi && pip install requests builtwith python-whois colorama dnspython

# Setup termux font
if [ ! -f ~/.termux/font.ttf ]; then
  echo "[+] Setting hacker-style font..."
  mkdir -p ~/.termux
  FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
  curl -fsSL -o ~/.termux/font.ttf "$FONT_URL"
  echo "font_size=14" > ~/.termux/termux.properties
  termux-reload-settings
else
  echo "[✓] Termux font already set."
fi

# Install figlet and lolcat
for tool in figlet toilet ncurses-utils; do
  if ! command -v $tool >/dev/null 2>&1; then
    pkg install -y $tool
  fi
done

pip install lolcat

# Oh My Zsh
if [ ! -d ~/.oh-my-zsh ]; then
  echo "[+] Installing Oh My Zsh..."
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
  echo "[✓] Oh My Zsh already installed."
fi

ZSH_CUSTOM=~/.oh-my-zsh/custom

git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions

git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions

# Configure Zsh
sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc

echo 'export PROMPT="%F{green}Termux💖CPA%f %1~ %# "' >> ~/.zshrc

cat << 'EOBANNER' >> ~/.zshrc

# CPA Centered Figlet Banner + Spinner
if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
  clear
  width=$(tput cols)
  text="C P A"
  font="slant"
  banner=$(figlet -f $font "$text")
  while IFS= read -r line; do
    printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"
  done <<< "$banner" | lolcat
  echo

  subtitle="Cyber People Attack"
  separator="==========================="
  printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle" | lolcat
  printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator" | lolcat

  echo
  echo -n "Initializing "
  spinner="/-\|"
  for i in $(seq 1 8); do
    for j in $(seq 0 3); do
      printf "\b${spinner:$j:1}"
      sleep 0.1
    done
  done
  echo -e "\b Ready! 🚀"
fi
EOBANNER

chsh -s zsh

echo "[+] Installation complete. Please restart Termux or run 'source ~/.zshrc'"
echo "[!] Enjoy CyberPeopleAttack Mini Distro! ⚔️"