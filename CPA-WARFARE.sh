#!/bin/bash

# CyberPeopleAttack Warfare Installer v2025
# Created by HARPY 🦅 — Offensive System Forge

clear
cat << "EOF"
=============================================
     _   _   _   _   _   _   _   _   _   _  
    / \ / \ / \ / \ / \ / \ / \ / \ / \ / \ 
   ( C | P | A | - | W | A | R | F | A | R )
    \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ \_/ 
=============================================
  CYBER OPS • OFFENSIVE ENGINE • TERMINAL
EOF

trap 'echo -e "\n[!] Installation interrupted. Exiting..."; exit 1' INT

echo "[+] Updating system..."
pkg update -y && pkg upgrade -y

echo "[+] Installing core packages..."
pkg install -y python git curl wget zsh figlet toilet ncurses-utils dialog clang golang nodejs exiftool nmap

echo "[+] Setting up pip/pipx..."
python -m ensurepip
python -m pip install --upgrade pip
python -m pip install pipx
pipx ensurepath

# --- INSTALL SQLMAP ---
echo "[+] Installing sqlmap..."
git clone --depth 1 https://github.com/sqlmapproject/sqlmap.git ~/sqlmap

# --- INSTALL OSINT TOOLS ---
echo "[+] Installing Photon..."
git clone https://github.com/s0md3v/Photon.git ~/photon
pip install -r ~/photon/requirements.txt

echo "[+] Installing theHarvester..."
pkg install libxml2 libxslt -y
git clone https://github.com/laramies/theHarvester.git ~/theHarvester
pip install -r ~/theHarvester/requirements/base.txt

echo "[+] Installing ReconDog..."
git clone https://github.com/s0md3v/ReconDog.git ~/ReconDog
pip install -r ~/ReconDog/requirements.txt
chmod +x ~/ReconDog/dog.py

echo "[+] Installing Sherlock..."
git clone https://github.com/sherlock-project/sherlock.git ~/sherlock
pip install -r ~/sherlock/requirements.txt

echo "[+] Installing Amass..."
pkg install -y amass

# --- INSTALL CPA TOOLS ---
declare -A repos=(
  [LOIC]="https://github.com/whitehat57/LOIC.git"
  [cpa]="https://gitlab.com/whitehat57/cpa.git"
  [karma-go]="https://gitlab.com/whitehat57/karma-go.git"
  [techstack]="https://gitlab.com/whitehat57/techstack.git"
)

echo "[+] Cloning CPA tools..."
for dir in "${!repos[@]}"; do
  if [ ! -d "$HOME/$dir" ]; then
    git clone "${repos[$dir]}" "$HOME/$dir"
  else
    echo "[✓] $dir already cloned."
  fi
done

echo "[+] Building CPA..."
cd ~/cpa && go mod download && go get github.com/fatih/color@v1.15.0 && go build -o main main.go

echo "[+] Building karma-go..."
cd ~/karma-go && go mod download && go get golang.org/x/net/idna@v0.21.0 github.com/fatih/color@v1.16.0 && go build -o karma *.go

echo "[+] Installing techstack requirements..."
cd ~/techstack && pkg install -y clang openssl libffi && pip install requests builtwith python-whois colorama dnspython

# --- GENERATE CPA DASHBOARD ---
echo "[+] Generating CPA Dashboard..."
cat << 'EOF' > ~/CPA-Dashboard.sh
#!/bin/bash

while true; do
    CHOICE=$(dialog --clear --backtitle "CyberPeopleAttack Dashboard" \
        --title "🦅 CPA CONTROL CENTER" \
        --menu "Select your weapon:" 20 70 14 \
        1 "Nmap Port Scanner" \
        2 "SQLMap Injection Test" \
        3 "Photon Web Crawler" \
        4 "theHarvester Recon" \
        5 "ReconDog All-in-One" \
        6 "Sherlock Username Hunt" \
        7 "ExifTool (Metadata)" \
        8 "Amass Subdomain Recon" \
        9 "LOIC (Layer 4/7 DDoS)" \
        10 "CPA Tool (Go Attacker)" \
        11 "Karma-Go (Recon+Attack)" \
        12 "Techstack Analyzer" \
        13 "Exit" \
        3>&1 1>&2 2>&3)

    clear
    case $CHOICE in
        1)
            ip=$(dialog --inputbox "Enter IP/Domain to scan:" 8 40 3>&1 1>&2 2>&3)
            nmap -sV "$ip" | tee ~/scan_$ip.txt
            dialog --textbox ~/scan_$ip.txt 20 70
            ;;
        2)
            url=$(dialog --inputbox "Enter URL to test with SQLMap:" 8 50 3>&1 1>&2 2>&3)
            python3 ~/sqlmap/sqlmap.py -u "$url" --batch | tee ~/sqlmap_$url.txt
            dialog --textbox ~/sqlmap_$url.txt 20 70
            ;;
        3)
            target=$(dialog --inputbox "Enter website for Photon:" 8 50 3>&1 1>&2 2>&3)
            python3 ~/photon/photon.py -u "$target" -o ~/photon_out | tee ~/photon_log.txt
            dialog --textbox ~/photon_log.txt 20 70
            ;;
        4)
            domain=$(dialog --inputbox "Domain for theHarvester:" 8 40 3>&1 1>&2 2>&3)
            python3 ~/theHarvester/theHarvester.py -d $domain -b all | tee ~/harvest_$domain.txt
            dialog --textbox ~/harvest_$domain.txt 20 70
            ;;
        5)
            cd ~/ReconDog && python3 dog.py
            ;;
        6)
            username=$(dialog --inputbox "Username for Sherlock:" 8 40 3>&1 1>&2 2>&3)
            python3 ~/sherlock/sherlock.py $username | tee ~/sherlock_$username.txt
            dialog --textbox ~/sherlock_$username.txt 20 70
            ;;
        7)
            file=$(dialog --inputbox "Enter image/document file path:" 8 60 3>&1 1>&2 2>&3)
            exiftool "$file" | tee ~/exif_$file.txt
            dialog --textbox ~/exif_$file.txt 20 70
            ;;
        8)
            domain=$(dialog --inputbox "Domain for Amass:" 8 40 3>&1 1>&2 2>&3)
            amass enum -d $domain | tee ~/amass_$domain.txt
            dialog --textbox ~/amass_$domain.txt 20 70
            ;;
        9)
            cd ~/LOIC && chmod +x LOIC && ./LOIC
            ;;
        10)
            cd ~/cpa && ./main
            ;;
        11)
            cd ~/karma-go && ./karma
            ;;
        12)
            read -p "Enter target URL: " url
            cd ~/techstack && python3 techstack.py "$url" | tee ~/techstack_$url.txt
            dialog --textbox ~/techstack_$url.txt 20 70
            ;;
        13)
            break
            ;;
    esac
done

clear
EOF

chmod +x ~/CPA-Dashboard.sh

# --- SET ALIASES ---
echo 'alias dashboard="bash ~/CPA-Dashboard.sh"' >> ~/.zshrc
echo 'alias loic="~/LOIC/LOIC"' >> ~/.zshrc
echo 'alias cpa="~/cpa/main"' >> ~/.zshrc
echo 'alias karma="~/karma-go/karma"' >> ~/.zshrc
echo 'alias tech="cd ~/techstack && python3 techstack.py"' >> ~/.zshrc

# --- CPA BANNER ---
cat << 'EOBANNER' >> ~/.zshrc

# CPA Banner on Zsh Login
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

# --- DONE ---
clear
figlet "CPA Warfare Ready" | lolcat
echo "[✓] All offensive and OSINT tools are installed."
echo "[✓] Run 'dashboard' to access the CPA Control Center."
echo "[✓] Welcome to the WARZONE, Operative. Stay sharp. 🦅"
