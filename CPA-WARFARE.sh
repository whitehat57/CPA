#!/bin/bash

# CPA Warfare Installer v2025 - Fixed Version
# Fixed various issues and improved error handling

clear
echo "============================================="
echo "   C Y B E R  P E O P L E  A T T A C K 💥   "
echo "        W A R F A R E   S Y S T E M         "
echo "============================================="

# Improved error handling
set -e
trap 'echo -e "\n[!] Installation interrupted or failed at line $LINENO."; exit 1' INT ERR

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to log messages
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting CPA Warfare installation..."

# Check if running on Termux
if [ -z "$TERMUX_VERSION" ]; then
    log "Warning: This script is designed for Termux environment"
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

log "Updating system..."
if command_exists pkg; then
    pkg update -y && pkg upgrade -y
else
    log "Error: pkg command not found. Are you running this on Termux?"
    exit 1
fi

log "Installing base packages..."
# Fixed: Added missing packages and proper error handling
PACKAGES=(
    git curl wget zsh figlet toilet ncurses-utils dialog
    clang golang python nodejs exiftool nmap lolcat
    python-pip
)

for package in "${PACKAGES[@]}"; do
    if ! pkg install -y "$package"; then
        log "Warning: Failed to install $package, continuing..."
    fi
done

log "Setting up Python environment..."
# Fixed: Better Python setup
if command_exists python3; then
    PYTHON_CMD="python3"
elif command_exists python; then
    PYTHON_CMD="python"
else
    log "Error: Python not found"
    exit 1
fi

# Install pip if not available
if ! command_exists pip && ! command_exists pip3; then
    $PYTHON_CMD -m ensurepip --upgrade
fi

# Use pip3 if available, otherwise pip
if command_exists pip3; then
    PIP_CMD="pip3"
else
    PIP_CMD="pip"
fi

$PIP_CMD install --upgrade pip
$PIP_CMD install pipx

# Fixed: Proper pipx path setup
if [ -f ~/.local/bin/pipx ]; then
    export PATH="$HOME/.local/bin:$PATH"
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
fi

log "Installing Oh My Zsh..."
# Fixed: Better Oh My Zsh installation with error handling
if [ ! -d ~/.oh-my-zsh ]; then
    if command_exists curl; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    else
        log "Error: curl not found, cannot install Oh My Zsh"
        exit 1
    fi
else
    log "Oh My Zsh already installed, skipping..."
fi

log "Installing Zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

# Fixed: Better plugin installation with error handling
PLUGINS=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions:https://github.com/zsh-users/zsh-completions"
)

for plugin_info in "${PLUGINS[@]}"; do
    plugin_name="${plugin_info%%:*}"
    plugin_url="${plugin_info##*:}"
    
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
        if ! git clone "$plugin_url" "$ZSH_CUSTOM/plugins/$plugin_name"; then
            log "Warning: Failed to install $plugin_name plugin"
        fi
    else
        log "$plugin_name plugin already installed"
    fi
done

log "Configuring .zshrc..."
# Fixed: Better .zshrc configuration
if [ -f ~/.zshrc ]; then
    # Backup existing .zshrc
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    
    # Update plugins line
    if grep -q "^plugins=" ~/.zshrc; then
        sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' ~/.zshrc
    else
        echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> ~/.zshrc
    fi
    
    # Add custom prompt
    if ! grep -q "export PROMPT=" ~/.zshrc; then
        echo 'export PROMPT="%F{green}Termux💖CPA%f %1~ %# "' >> ~/.zshrc
    fi
else
    log "Warning: .zshrc not found, Oh My Zsh installation may have failed"
fi

log "Setting up Termux font..."
# Fixed: Better font installation
mkdir -p ~/.termux
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/complete/Hack%20Regular%20Nerd%20Font%20Complete.ttf"
if command_exists curl; then
    if curl -fsSL -o ~/.termux/font.ttf "$FONT_URL"; then
        echo "font_size=14" > ~/.termux/termux.properties
        # Fixed: Only reload settings if in Termux
        if command_exists termux-reload-settings; then
            termux-reload-settings
        fi
    else
        log "Warning: Failed to download font"
    fi
else
    log "Warning: curl not available for font download"
fi

log "Cloning CPA tools..."
# Fixed: Better repository handling
declare -A repos=(
    ["LOIC"]="https://github.com/whitehat57/LOIC.git"
    ["cpa"]="https://gitlab.com/whitehat57/cpa.git"
    ["karma-go"]="https://gitlab.com/whitehat57/karma-go.git"
    ["techstack"]="https://gitlab.com/whitehat57/techstack.git"
    ["sqlmap"]="https://github.com/sqlmapproject/sqlmap.git"
    ["photon"]="https://github.com/s0md3v/Photon.git"
    ["theHarvester"]="https://github.com/laramies/theHarvester.git"
    ["ReconDog"]="https://github.com/s0md3v/ReconDog.git"
    ["sherlock"]="https://github.com/sherlock-project/sherlock.git"
)

for tool in "${!repos[@]}"; do
    if [ ! -d ~/"$tool" ]; then
        log "Cloning $tool..."
        if ! git clone "${repos[$tool]}" ~/"$tool"; then
            log "Warning: Failed to clone $tool"
        fi
    else
        log "$tool already exists, skipping..."
    fi
done

log "Building and setting up tools..."
# Fixed: Better error handling for tool setup
cd ~ || exit 1

# Build CPA
if [ -d ~/cpa ]; then
    cd ~/cpa || exit 1
    if command_exists go; then
        go mod download && go get github.com/fatih/color@v1.15.0 && go build -o main main.go
    else
        log "Warning: Go not found, skipping CPA build"
    fi
fi

# Build Karma-Go
if [ -d ~/karma-go ]; then
    cd ~/karma-go || exit 1
    if command_exists go; then
        go mod download && go get golang.org/x/net/idna@v0.21.0 github.com/fatih/color@v1.16.0 && go build -o karma .
    else
        log "Warning: Go not found, skipping Karma-Go build"
    fi
fi

# Setup Python tools
PYTHON_TOOLS=(
    "techstack:requests builtwith python-whois colorama dnspython"
    "photon:requirements.txt"
    "theHarvester:requirements/base.txt"
    "ReconDog:requirements.txt"
    "sherlock:requirements.txt"
)

for tool_info in "${PYTHON_TOOLS[@]}"; do
    tool_name="${tool_info%%:*}"
    requirements="${tool_info##*:}"
    
    if [ -d ~/"$tool_name" ]; then
        cd ~/"$tool_name" || continue
        if [ "$requirements" = "requirements.txt" ] || [ "$requirements" = "requirements/base.txt" ]; then
            if [ -f "$requirements" ]; then
                $PIP_CMD install -r "$requirements" || log "Warning: Failed to install requirements for $tool_name"
            fi
        else
            $PIP_CMD install $requirements || log "Warning: Failed to install packages for $tool_name"
        fi
        
        # Make executable if needed
        if [ -f "dog.py" ]; then
            chmod +x dog.py
        fi
    fi
done

log "Creating CPA dashboard..."
# Fixed: Better dashboard script with error handling
cat << 'EOF' > ~/CPA-Dashboard.sh
#!/bin/bash

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run tool safely
run_tool() {
    local tool_path="$1"
    local tool_name="$2"
    
    if [ -f "$tool_path" ]; then
        cd "$(dirname "$tool_path")" && ./"$(basename "$tool_path")"
    else
        echo "Error: $tool_name not found at $tool_path"
        read -p "Press Enter to continue..."
    fi
}

while true; do
    if command_exists dialog; then
        CHOICE=$(dialog --clear --backtitle "CPA Dashboard" --title "🦅 CONTROL CENTER" --menu "Select Tool:" 20 70 14 \
        1 "Nmap Scanner" \
        2 "SQLMap" \
        3 "Photon" \
        4 "theHarvester" \
        5 "ReconDog" \
        6 "Sherlock" \
        7 "ExifTool" \
        8 "LOIC" \
        9 "CPA" \
        10 "Karma-Go" \
        11 "Techstack" \
        12 "Exit" 3>&1 1>&2 2>&3)
        
        clear
        case $CHOICE in
        1) 
            read -p "Target IP/Domain: " ip
            if [ -n "$ip" ]; then
                nmap -sV "$ip" | tee ~/scan_"$ip".txt
                if command_exists dialog; then
                    dialog --textbox ~/scan_"$ip".txt 20 70
                fi
            fi
            ;;
        2) 
            read -p "URL: " url
            if [ -n "$url" ] && [ -f ~/sqlmap/sqlmap.py ]; then
                python3 ~/sqlmap/sqlmap.py -u "$url" --batch
            fi
            ;;
        3) 
            read -p "Website: " target
            if [ -n "$target" ] && [ -f ~/photon/photon.py ]; then
                python3 ~/photon/photon.py -u "$target" -o ~/photon_out
            fi
            ;;
        4) 
            read -p "Domain: " d
            if [ -n "$d" ] && [ -f ~/theHarvester/theHarvester.py ]; then
                python3 ~/theHarvester/theHarvester.py -d "$d" -b all
            fi
            ;;
        5) 
            if [ -f ~/ReconDog/dog.py ]; then
                cd ~/ReconDog && python3 dog.py
            fi
            ;;
        6) 
            read -p "Username: " u
            if [ -n "$u" ] && [ -f ~/sherlock/sherlock.py ]; then
                python3 ~/sherlock/sherlock.py "$u"
            fi
            ;;
        7) 
            read -p "File path: " f
            if [ -n "$f" ] && [ -f "$f" ]; then
                exiftool "$f"
            fi
            ;;
        8) run_tool ~/LOIC/LOIC "LOIC" ;;
        9) run_tool ~/cpa/main "CPA" ;;
        10) run_tool ~/karma-go/karma "Karma-Go" ;;
        11) 
            read -p "URL: " u
            if [ -n "$u" ] && [ -f ~/techstack/techstack.py ]; then
                cd ~/techstack && python3 techstack.py "$u"
            fi
            ;;
        12) break ;;
        esac
    else
        echo "Dialog not available. Please install dialog package."
        break
    fi
done
EOF

chmod +x ~/CPA-Dashboard.sh

log "Setting up aliases..."
# Fixed: Better alias setup
ALIASES=(
    'alias dashboard="bash ~/CPA-Dashboard.sh"'
    'alias loic="cd ~/LOIC && ./LOIC"'
    'alias cpa="cd ~/cpa && ./main"'
    'alias karma="cd ~/karma-go && ./karma"'
    'alias tech="cd ~/techstack && python3 techstack.py"'
)

for alias_cmd in "${ALIASES[@]}"; do
    if ! grep -q "$alias_cmd" ~/.zshrc 2>/dev/null; then
        echo "$alias_cmd" >> ~/.zshrc
    fi
done

log "Setting up CPA banner..."
# Fixed: Better banner setup
cat << 'EOBANNER' >> ~/.zshrc

# CPA Banner
if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    clear
    width=$(tput cols 2>/dev/null || echo 80)
    text="C P A"
    banner=$(figlet -f slant "$text" 2>/dev/null || figlet "$text" 2>/dev/null || echo "$text")
    
    while IFS= read -r line; do 
        printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"
    done <<< "$banner" | lolcat 2>/dev/null || echo "$banner"
    
    echo
    subtitle="Cyber People Attack"
    separator="==========================="
    printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle" | lolcat 2>/dev/null || echo "$subtitle"
    printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator" | lolcat 2>/dev/null || echo "$separator"
    echo
    
    echo -n "Initializing "
    spinner="/-\|"
    for i in $(seq 1 4); do 
        for j in $(seq 0 3); do 
            printf "\b${spinner:$j:1}"
            sleep 0.1
        done
    done
    echo -e "\b Ready! 🚀"
    echo
fi
EOBANNER

# Fixed: Better shell change
if command_exists zsh; then
    log "Setting zsh as default shell..."
    # Change default shell if possible
    if command_exists chsh; then
        chsh -s "$(which zsh)" 2>/dev/null || log "Warning: Could not change default shell"
    fi
fi

clear
if command_exists figlet && command_exists lolcat; then
    figlet "CPA Ready" | lolcat
else
    echo "=========================================="
    echo "           CPA READY                     "
    echo "=========================================="
fi

log "Installation completed successfully!"
echo
echo "Available commands:"
echo "  dashboard  - Open CPA control center"
echo "  loic       - Launch LOIC"
echo "  cpa        - Launch CPA tool"
echo "  karma      - Launch Karma-Go"
echo "  tech       - Launch Techstack"
echo
echo "To start using CPA, run: source ~/.zshrc && dashboard"