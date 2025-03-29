#!/bin/bash

# CyberPeopleAttack + Oh My Zsh Integrated Installer (No CPA_TOOLS)
clear
echo "============================================="
echo "  CPA & Zsh Direct Installer v2025           "
echo "============================================="
echo "      _   _   _   _   _   _   _   _         "
echo "     / \ / \ / \ / \ / \ / \ / \ / \        "
echo "    ( D | i | r | e | c | t | - | ! )      "
echo "     \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/        "
echo "============================================="

echo "[+] Initializing direct installation..."

# Function to handle errors
handle_error() {
  echo -e "\n[!] Error pada langkah: $1"
  echo "[!] Silakan cek koneksi internet atau permission"
  exit 1
}

# Install basic dependencies
echo "[+] Memperbarui paket dan instalasi dependensi..."
pkg update -y && pkg upgrade -y
pkg install -y git curl zsh unzip ncurses-utils python || handle_error "Instalasi dependensi dasar"

# CyberPeopleAttack Direct Installation
echo -e "\n[+] Memulai instalasi CyberPeopleAttack..."
if [ ! -d ~/CyberPeopleAttack ]; then
  git clone https://github.com/whitehat57/CyberPeopleAttack.git ~/CyberPeopleAttack || handle_error "Clone CPA"
fi

# Langsung install requirements.txt jika ada
if [ -f ~/CyberPeopleAttack/requirements.txt ]; then
  pip install -r ~/CyberPeopleAttack/requirements.txt || handle_error "Install Python dependencies"
fi

# Font Installation
echo -e "\n[+] Mengatur font hacker..."
mkdir -p ~/.termux
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
curl -fsSL -o ~/.termux/font.ttf "$FONT_URL" && {
  echo "font_size=14" > ~/.termux/termux.properties
  termux-reload-settings
} || echo "[!] Gagal instalasi font, melanjutkan..."

# Oh My Zsh Installation
echo -e "\n[+] Memulai instalasi Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended || handle_error "Instalasi Oh My Zsh"

# Plugin Installation langsung ke direktori Zsh
echo -e "\n[+] Menginstal plugin Zsh..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

install_plugin() {
  repo="$1"
  plugin_dir="$2"
  if [ ! -d "$plugin_dir" ]; then
    git clone --depth 1 "$repo" "$plugin_dir" || handle_error "Clone $repo"
  fi
}

# Install plugins langsung ke direktori Zsh
install_plugin "https://github.com/zsh-users/zsh-autosuggestions" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
install_plugin "https://github.com/zsh-users/zsh-syntax-highlighting" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
install_plugin "https://github.com/zsh-users/zsh-completions" "$ZSH_CUSTOM/plugins/zsh-completions"
install_plugin "https://github.com/romkatv/powerlevel10k" "$ZSH_CUSTOM/themes/powerlevel10k"

# Konfigurasi Zsh langsung di home
echo -e "\n[+] Membuat konfigurasi Zsh..."
cat > ~/.zshrc <<- EOM
export ZSH="\$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  zsh-completions
)

source \$ZSH/oh-my-zsh.sh

# Auto-completion
autoload -U compinit && compinit

# CPA Alias
alias cpa="python3 ~/CyberPeopleAttack/cpa.py"
alias cpaconfig="nano ~/CyberPeopleAttack/config.cpa"

# Custom Prompt
PS1='%F{cyan}CPA-%f%F{green}%n%f:%F{blue}%~%f\$ '

# Environment Path
export PATH=\$PATH:~/CyberPeopleAttack/bin

# Powerlevel10k Config
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOM

# Final Setup
echo -e "\n[+] Finalisasi instalasi..."
echo "exec zsh" >> ~/.bashrc
chsh -s zsh || handle_error "Ganti shell ke Zsh"

echo -e "\n[+] Instalasi selesai!"
echo "============================================="
echo " Struktur Direktori:"
echo " - CyberPeopleAttack  : ~/CyberPeopleAttack"
echo " - Oh My Zsh          : ~/.oh-my-zsh"
echo " - Konfigurasi Zsh    : ~/.zshrc"
echo "============================================="
echo " Cara penggunaan:"
echo " 1. Tutup dan buka kembali Termux"
echo " 2. Ketik 'cpa' untuk menjalankan CPA"
echo " 3. Edit config: 'cpaconfig'"
echo "============================================="
