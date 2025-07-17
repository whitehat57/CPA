#!/bin/bash

# CPA Warfare Installer v2025 - Final Stable
# Powered by HARPY 🦅

clear
echo "============================================="
echo "   C Y B E R  P E O P L E  A T T A C K 💥   "
echo "        W A R F A R E   S Y S T E M         "
echo "============================================="

trap 'echo -e "\n[!] Installation interrupted."; exit 1' INT

echo "[+] Updating system..."
pkg update -y && pkg upgrade -y

echo "[+] Installing base packages..."
pkg install -y git curl wget zsh figlet toilet ncurses-utils dialog clang golang python nodejs exiftool nmap lolcat

echo "[+] Installing pip & pipx..."
python -m ensurepip
python -m pip install --upgrade pip
python -m pip install pipx
pipx ensurepath

echo "[+] Installing Oh My Zsh..."
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

echo "[+] Installing Zsh plugins..."
ZSH_CUSTOM=~/.oh-my-zsh/custom
git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions

echo "[+] Configuring .zshrc..."
sed -i 's/^plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc
echo 'export PROMPT="%F{green}Termux💖CPA%f %1~ %# "' >> ~/.zshrc
echo "[+] Setting Termux Nerd Font..."
mkdir -p ~/.termux
curl -fsSL -o ~/.termux/font.ttf "https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
echo "font_size=14" > ~/.termux/termux.properties
termux-reload-settings

echo "[+] Cloning CPA tools..."
declare -A repos=(
  [LOIC]="https://github.com/whitehat57/LOIC.git"
  [cpa]="https://gitlab.com/whitehat57/cpa.git"
  [karma-go]="https://gitlab.com/whitehat57/karma-go.git"
  [techstack]="https://gitlab.com/whitehat57/techstack.git"
  [sqlmap]="https://github.com/sqlmapproject/sqlmap.git"
  [photon]="https://github.com/s0md3v/Photon.git"
  [theHarvester]="https://github.com/laramies/theHarvester.git"
  [ReconDog]="https://github.com/s0md3v/ReconDog.git"
  [sherlock]="https://github.com/sherlock-project/sherlock.git"
)

for tool in "${!repos[@]}"; do
  [ -d ~/$tool ] || git clone "${repos[$tool]}" ~/$tool
done

echo "[+] Building CPA & Karma-Go..."
cd ~/cpa && go mod download && go get github.com/fatih/color@v1.15.0 && go build -o main main.go
cd ~/karma-go && go mod download && go get golang.org/x/net/idna@v0.21.0 github.com/fatih/color@v1.16.0 && go build -o karma *.go
cd ~/techstack && pip install requests builtwith python-whois colorama dnspython
cd ~/photon && pip install -r requirements.txt
cd ~/theHarvester && pip install -r requirements/base.txt
cd ~/ReconDog && pip install -r requirements.txt && chmod +x dog.py
cd ~/sherlock && pip install -r requirements.txt
echo "[+] Creating CPA dashboard..."
cat << 'EOF' > ~/CPA-Dashboard.sh
#!/bin/bash
while true; do
CHOICE=$(dialog --clear --backtitle "CPA Dashboard" --title "🦅 CONTROL CENTER" --menu "Select Tool:" 20 70 14 \
1 "Nmap Scanner" \
2 "SQLMap" \
3 "Photon" \
4 "theHarvester" \
5 "ReconDog" \
6 "Sherlock" \
7 "ExifTool" \
8 "Amass" \
9 "LOIC" \
10 "CPA" \
11 "Karma-Go" \
12 "Techstack" \
13 "Exit" 3>&1 1>&2 2>&3)
clear
case $CHOICE in
1) read -p "Target: " ip; nmap -sV $ip | tee ~/scan_$ip.txt; dialog --textbox ~/scan_$ip.txt 20 70 ;;
2) read -p "URL: " url; python3 ~/sqlmap/sqlmap.py -u "$url" --batch ;;
3) read -p "Site: " target; python3 ~/photon/photon.py -u "$target" -o ~/photon_out ;;
4) read -p "Domain: " d; python3 ~/theHarvester/theHarvester.py -d $d -b all ;;
5) cd ~/ReconDog && python3 dog.py ;;
6) read -p "Username: " u; python3 ~/sherlock/sherlock.py $u ;;
7) read -p "File path: " f; exiftool "$f" ;;
8) read -p "Domain: " d; amass enum -d $d ;;
9) cd ~/LOIC && chmod +x LOIC && ./LOIC ;;
10) cd ~/cpa && ./main ;;
11) cd ~/karma-go && ./karma ;;
12) read -p "URL: " u; cd ~/techstack && python3 techstack.py "$u" ;;
13) break ;;
esac
done
EOF

chmod +x ~/CPA-Dashboard.sh
echo 'alias dashboard="bash ~/CPA-Dashboard.sh"' >> ~/.zshrc
echo 'alias loic="~/LOIC/LOIC"' >> ~/.zshrc
echo 'alias cpa="~/cpa/main"' >> ~/.zshrc
echo 'alias karma="~/karma-go/karma"' >> ~/.zshrc
echo 'alias tech="cd ~/techstack && python3 techstack.py"' >> ~/.zshrc

# CPA Banner
cat << 'EOBANNER' >> ~/.zshrc
if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
  clear
  width=$(tput cols)
  text="C P A"
  font="slant"
  banner=$(figlet -f $font "$text")
  while IFS= read -r line; do printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"; done <<< "$banner" | lolcat
  echo
  subtitle="Cyber People Attack"
  separator="==========================="
  printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle" | lolcat
  printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator" | lolcat
  echo
  echo -n "Initializing "
  spinner="/-\|"
  for i in $(seq 1 8); do for j in $(seq 0 3); do printf "\b${spinner:$j:1}"; sleep 0.1; done; done
  echo -e "\b Ready! 🚀"
fi
EOBANNER

chsh -s zsh
clear
figlet "CPA Ready" | lolcat
echo "[✓] All tools installed. Type 'dashboard' to begin mission."
