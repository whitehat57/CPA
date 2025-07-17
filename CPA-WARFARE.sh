#!/bin/bash

# CPA Warfare Installer v2025 - Fixed Version
# Fixed various issues and improved error handling

clear
echo "============================================="
echo "   C Y B E R  P E O P L E  A T T A C K 💥   "
echo "         W A R F A R E   S Y S T E M       "
echo "============================================="

# Improved error handling: Exit immediately if a command exits with a non-zero status.
# Trap signals (INT for Ctrl+C, ERR for any command error) to provide informative messages.
set -e
trap 'echo -e "\n[!] Installation interrupted or failed at line $LINENO."; exit 1' INT ERR

# Function to check if a command exists in the system's PATH.
# Usage: command_exists <command_name>
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to log messages with a timestamp.
# Usage: log "Your message here"
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1"
}

log "Starting CPA Warfare installation..."

# Check if the script is running in a Termux environment.
# If not, it issues a warning and asks for user confirmation to proceed.
if [ -z "$TERMUX_VERSION" ]; then
    log "Warning: This script is primarily designed for the Termux environment."
    read -p "Continue anyway? (y/N): " -n 1 -r
    echo # Add a newline after the read -n 1
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log "Installation aborted by user."
        exit 1
    fi
    log "Continuing installation outside Termux (may encounter issues)."
fi

log "Updating system packages..."
# Update and upgrade Termux packages.
# Checks if 'pkg' command exists before attempting to use it.
if command_exists pkg; then
    if ! pkg update -y; then
        log "Warning: Failed to update packages. Continuing anyway."
    fi
    if ! pkg upgrade -y; then
        log "Warning: Failed to upgrade packages. Continuing anyway."
    fi
else
    log "Error: 'pkg' command not found. This script requires Termux."
    exit 1
fi

log "Installing base packages..."
# Define an array of required base packages.
# lolcat is removed from here as it's a Ruby gem, installed separately.
PACKAGES=(
    "git" "curl" "wget" "zsh" "figlet" "toilet" "ncurses-utils" "dialog"
    "clang" "golang" "python" "nodejs" "exiftool" "nmap" "ruby"
    "python-pip" # python-pip is often installed with 'python' or 'python3', but included for robustness.
)

# Loop through the packages and install them. Log a warning if any package fails to install.
for package in "${PACKAGES[@]}"; do
    if ! pkg install -y "$package"; then
        log "Warning: Failed to install '$package'. Continuing installation."
    fi
done

log "Installing Ruby gems (e.g., lolcat)..."
# Install lolcat using gem. Checks if 'gem' command is available.
if command_exists gem; then
    # Attempt to update the gem system. Suppress errors and log a warning if it fails.
    if ! gem update --system --no-document 2>/dev/null; then
        log "Warning: Could not update gem system."
    fi
    
    # Install lolcat gem. Log a warning if it fails.
    if ! gem install lolcat --no-document; then
        log "Warning: Failed to install 'lolcat' gem."
    else
        log "'lolcat' gem installed successfully."
    fi
else
    log "Warning: 'gem' command not found. Skipping 'lolcat' installation."
fi

log "Setting up Python environment..."
# Determine the correct Python command (python3 preferred).
PYTHON_CMD=""
if command_exists python3; then
    PYTHON_CMD="python3"
elif command_exists python; then
    PYTHON_CMD="python"
else
    log "Error: Python (python3 or python) not found. Please install Python."
    exit 1
fi
log "Using Python command: $PYTHON_CMD"

# Install pip if not available using ensurepip.
if ! command_exists pip && ! command_exists pip3; then
    log "Pip not found, installing via ensurepip..."
    if ! "$PYTHON_CMD" -m ensurepip --upgrade; then
        log "Warning: Failed to install pip via ensurepip."
    fi
fi

# Determine the correct pip command (pip3 preferred).
PIP_CMD=""
if command_exists pip3; then
    PIP_CMD="pip3"
elif command_exists pip; then
    PIP_CMD="pip"
else
    log "Error: Pip (pip3 or pip) not found after installation attempt."
    exit 1
fi
log "Using Pip command: $PIP_CMD"

# Upgrade pip and install pipx.
log "Upgrading pip and installing pipx..."
if ! "$PIP_CMD" install --upgrade pip; then
    log "Warning: Failed to upgrade pip."
fi
if ! "$PIP_CMD" install pipx; then
    log "Warning: Failed to install pipx."
fi

# Set up pipx path in .zshrc for future sessions.
# Check if pipx executable exists before adding to PATH.
if [ -f "$HOME/.local/bin/pipx" ]; then
    log "Adding pipx to PATH in .zshrc..."
    # Export for current session
    export PATH="$HOME/.local/bin:$PATH"
    # Add to .zshrc for future sessions, ensuring it's not duplicated.
    if ! grep -q 'export PATH="$HOME/.local/bin:$PATH"' "$HOME/.zshrc" 2>/dev/null; then
        echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc"
    fi
else
    log "Warning: pipx executable not found at $HOME/.local/bin/pipx. PATH not updated."
fi

log "Installing Oh My Zsh..."
# Install Oh My Zsh if it's not already installed.
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    if command_exists curl; then
        log "Downloading and installing Oh My Zsh..."
        # Use --unattended for non-interactive installation.
        if sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
            log "Oh My Zsh installed successfully."
        else
            log "Warning: Oh My Zsh installation script failed."
        fi
    else
        log "Error: 'curl' not found. Cannot install Oh My Zsh."
        exit 1
    fi
else
    log "Oh My Zsh already installed, skipping installation."
fi

log "Installing Zsh plugins..."
# Define the custom directory for Zsh plugins.
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
mkdir -p "$ZSH_CUSTOM/plugins"

# Define an associative array of Zsh plugins (name:URL).
declare -a PLUGINS=(
    "zsh-autosuggestions:https://github.com/zsh-users/zsh-autosuggestions"
    "zsh-syntax-highlighting:https://github.com/zsh-users/zsh-syntax-highlighting"
    "zsh-completions:https://github.com/zsh-users/zsh-completions"
)

# Loop through the plugins and clone their repositories.
for plugin_info in "${PLUGINS[@]}"; do
    plugin_name="${plugin_info%%:*}" # Extract plugin name before ':'
    plugin_url="${plugin_info##*:}"  # Extract plugin URL after ':'
    
    if [ ! -d "$ZSH_CUSTOM/plugins/$plugin_name" ]; then
        log "Cloning $plugin_name plugin from $plugin_url..."
        if ! git clone "$plugin_url" "$ZSH_CUSTOM/plugins/$plugin_name"; then
            log "Warning: Failed to install '$plugin_name' plugin."
        else
            log "'$plugin_name' plugin installed successfully."
        fi
    else
        log "'$plugin_name' plugin already installed, skipping."
    fi
done

log "Configuring .zshrc..."
# Configure the .zshrc file.
if [ -f "$HOME/.zshrc" ]; then
    log "Backing up existing .zshrc to .zshrc.backup.$(date +%Y%m%d_%H%M%S)..."
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"
    
    log "Updating plugins line in .zshrc..."
    # Use sed to update the plugins line. If it doesn't exist, append it.
    if grep -q "^plugins=" "$HOME/.zshrc"; then
        sed -i 's/^plugins=.*/plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)/' "$HOME/.zshrc"
    else
        echo 'plugins=(git zsh-autosuggestions zsh-syntax-highlighting zsh-completions)' >> "$HOME/.zshrc"
    fi
    
    log "Adding custom prompt to .zshrc..."
    # Add a custom prompt if it's not already present.
    if ! grep -q "export PROMPT=" "$HOME/.zshrc"; then
        echo 'export PROMPT="%F{green}Termux💖CPA%f %1~ %# "' >> "$HOME/.zshrc"
    fi
else
    log "Warning: .zshrc not found. Oh My Zsh installation may have failed or needs manual setup."
fi

log "Setting up Termux font..."
# Create Termux configuration directory if it doesn't exist.
mkdir -p "$HOME/.termux"
FONT_URL="https://github.com/ryanoasis/nerd-fonts/raw/master/patched-fonts/Hack/Regular/HackNerdFont-Regular.ttf"

if command_exists curl; then
    log "Attempting to download font from primary URL..."
    if curl -fsSL -o "$HOME/.termux/font.ttf" "$FONT_URL"; then
        log "Font downloaded successfully."
    else
        log "Warning: Failed to download font from primary URL. Trying alternative URL."
        ALT_FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/download/v3.0.2/Hack.zip"
        if curl -fsSL -o "$HOME/.termux/hack.zip" "$ALT_FONT_URL"; then
            if command_exists unzip; then
                log "Unzipping font from alternative source..."
                # Navigate to .termux, unzip, move .ttf, and clean up.
                (cd "$HOME/.termux" && unzip -j hack.zip "*.ttf" && mv *.ttf font.ttf && rm hack.zip)
                log "Font installed from alternative source."
            else
                log "Warning: 'unzip' command not available. Cannot extract font from ZIP."
            fi
        else
            log "Warning: Failed to download font from alternative source."
        fi
    fi
    
    log "Setting font configuration in ~/.termux/termux.properties..."
    # Set font size and family in Termux properties.
    echo "font_size=14" > "$HOME/.termux/termux.properties"
    echo "font_family=Hack" >> "$HOME/.termux/termux.properties"
    
    # Reload Termux settings if the command is available.
    if command_exists termux-reload-settings; then
        log "Reloading Termux settings..."
        termux-reload-settings
    else
        log "Warning: 'termux-reload-settings' command not found. You may need to restart Termux for font changes to apply."
    fi
else
    log "Warning: 'curl' not available for font download. Skipping font installation."
fi

log "Cloning CPA tools..."
# Define an associative array of tools (tool_name:repository_url).
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

# Loop through the tools and clone their repositories into the home directory.
for tool in "${!repos[@]}"; do
    if [ ! -d "$HOME/$tool" ]; then
        log "Cloning $tool from ${repos[$tool]}..."
        if ! git clone "${repos[$tool]}" "$HOME/$tool"; then
            log "Warning: Failed to clone '$tool'."
        else
            log "'$tool' cloned successfully."
        fi
    else
        log "'$tool' already exists in $HOME, skipping cloning."
    fi
done

log "Building and setting up tools..."
# Change to home directory to ensure relative paths work.
cd "$HOME" || { log "Error: Could not change to home directory."; exit 1; }

# Build CPA (Go project).
if [ -d "$HOME/cpa" ]; then
    log "Building CPA..."
    cd "$HOME/cpa" || { log "Error: Could not change to ~/cpa directory."; exit 1; }
    if command_exists go; then
        # Ensure Go modules are downloaded and build the project.
        if go mod download && go get github.com/fatih/color@v1.15.0 && go build -o main main.go; then
            log "CPA built successfully."
        else
            log "Warning: Failed to build CPA. Check Go installation and dependencies."
        fi
    else
        log "Warning: 'go' command not found. Skipping CPA build."
    fi
    cd "$HOME" # Return to home directory
fi

# Build Karma-Go (Go project).
if [ -d "$HOME/karma-go" ]; then
    log "Building Karma-Go..."
    cd "$HOME/karma-go" || { log "Error: Could not change to ~/karma-go directory."; exit 1; }
    if command_exists go; then
        # Ensure Go modules are downloaded and build the project.
        if go mod download && go get golang.org/x/net/idna@v0.21.0 github.com/fatih/color@v1.16.0 && go build -o karma .; then
            log "Karma-Go built successfully."
        else
            log "Warning: Failed to build Karma-Go. Check Go installation and dependencies."
        fi
    else
        log "Warning: 'go' command not found. Skipping Karma-Go build."
    fi
    cd "$HOME" # Return to home directory
fi

# Setup Python tools.
# Define an array of Python tools with their requirements.
declare -a PYTHON_TOOLS=(
    "techstack:requests builtwith python-whois colorama dnspython"
    "photon:requirements.txt"
    "theHarvester:requirements/base.txt"
    "ReconDog:requirements.txt"
    "sherlock:requirements.txt"
)

# Loop through Python tools, install requirements, and make scripts executable.
for tool_info in "${PYTHON_TOOLS[@]}"; do
    tool_name="${tool_info%%:*}"
    requirements="${tool_info##*:}"
    
    if [ -d "$HOME/$tool_name" ]; then
        log "Setting up Python tool: $tool_name..."
        cd "$HOME/$tool_name" || { log "Warning: Could not change to ~/$tool_name directory. Skipping setup for $tool_name."; continue; }
        
        if [ "$requirements" = "requirements.txt" ] || [ "$requirements" = "requirements/base.txt" ]; then
            # Install from requirements file if specified.
            if [ -f "$requirements" ]; then
                log "Installing requirements for $tool_name from $requirements..."
                if ! "$PIP_CMD" install -r "$requirements"; then
                    log "Warning: Failed to install requirements for '$tool_name'."
                else
                    log "Requirements for '$tool_name' installed."
                fi
            else
                log "Warning: Requirements file '$requirements' not found for '$tool_name'."
            fi
        else
            # Install specified packages directly.
            log "Installing direct packages for $tool_name: $requirements..."
            if ! "$PIP_CMD" install $requirements; then
                log "Warning: Failed to install packages for '$tool_name'."
            else
                log "Packages for '$tool_name' installed."
            fi
        fi
        
        # Make specific Python scripts executable if they exist.
        if [ -f "dog.py" ]; then
            log "Making dog.py executable for ReconDog..."
            chmod +x dog.py
        fi
        
        cd "$HOME" # Return to home directory
    else
        log "Warning: Tool directory $HOME/$tool_name not found. Skipping setup for $tool_name."
    fi
done

log "Creating CPA dashboard script..."
# Create the CPA Dashboard script.
# Using 'EOF' with single quotes prevents variable expansion inside the script.
cat << 'EOF' > "$HOME/CPA-Dashboard.sh"
#!/bin/bash

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to run a tool safely.
# It changes to the tool's directory, executes it, and then pauses.
run_tool() {
    local tool_path="$1"
    local tool_name="$2"
    
    if [ -f "$tool_path" ]; then
        echo "Launching $tool_name..."
        # Change directory to the tool's parent directory and execute.
        # Using 'exec' replaces the current shell process with the tool,
        # which might be desired for some tools, but for a menu,
        # it's better to run it in a subshell or directly.
        # Let's stick to simple execution for now.
        (cd "$(dirname "$tool_path")" && ./"$(basename "$tool_path")")
        echo "---------------------------------------------"
        read -p "Press Enter to return to the dashboard..."
    else
        echo "Error: $tool_name not found at $tool_path"
        read -p "Press Enter to continue..."
    fi
}

# Main loop for the dashboard menu.
while true; do
    # Check if 'dialog' command is available for the menu.
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
        
        clear # Clear screen after dialog selection.
        case $CHOICE in
            1) 
                read -p "Enter Target IP/Domain for Nmap: " ip
                if [ -n "$ip" ]; then
                    echo "Running Nmap scan on $ip..."
                    # Output scan results to a temporary file and display with dialog.
                    nmap -sV "$ip" | tee "$HOME/scan_result_$ip.txt"
                    if command_exists dialog; then
                        dialog --textbox "$HOME/scan_result_$ip.txt" 20 70
                    fi
                    rm -f "$HOME/scan_result_$ip.txt" # Clean up temporary file.
                else
                    echo "No target specified for Nmap."
                fi
                read -p "Press Enter to continue..."
                ;;
            2) 
                read -p "Enter URL for SQLMap: " url
                if [ -n "$url" ] && [ -f "$HOME/sqlmap/sqlmap.py" ]; then
                    echo "Running SQLMap on $url..."
                    python3 "$HOME/sqlmap/sqlmap.py" -u "$url" --batch
                else
                    echo "Invalid URL or SQLMap not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            3) 
                read -p "Enter Website for Photon: " target
                if [ -n "$target" ] && [ -f "$HOME/photon/photon.py" ]; then
                    echo "Running Photon on $target..."
                    python3 "$HOME/photon/photon.py" -u "$target" -o "$HOME/photon_out"
                else
                    echo "Invalid website or Photon not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            4) 
                read -p "Enter Domain for theHarvester: " d
                if [ -n "$d" ] && [ -f "$HOME/theHarvester/theHarvester.py" ]; then
                    echo "Running theHarvester on $d..."
                    python3 "$HOME/theHarvester/theHarvester.py" -d "$d" -b all
                else
                    echo "Invalid domain or theHarvester not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            5) 
                if [ -f "$HOME/ReconDog/dog.py" ]; then
                    echo "Launching ReconDog..."
                    (cd "$HOME/ReconDog" && python3 dog.py)
                else
                    echo "ReconDog not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            6) 
                read -p "Enter Username for Sherlock: " u
                if [ -n "$u" ] && [ -f "$HOME/sherlock/sherlock.py" ]; then
                    echo "Running Sherlock for username $u..."
                    python3 "$HOME/sherlock/sherlock.py" "$u"
                else
                    echo "Invalid username or Sherlock not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            7) 
                read -p "Enter File path for ExifTool: " f
                if [ -n "$f" ] && [ -f "$f" ]; then
                    echo "Running ExifTool on $f..."
                    exiftool "$f"
                else
                    echo "Invalid file path or file not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            8) run_tool "$HOME/LOIC/LOIC" "LOIC" ;;
            9) run_tool "$HOME/cpa/main" "CPA" ;;
            10) run_tool "$HOME/karma-go/karma" "Karma-Go" ;;
            11) 
                read -p "Enter URL for Techstack: " u
                if [ -n "$u" ] && [ -f "$HOME/techstack/techstack.py" ]; then
                    echo "Running Techstack on $u..."
                    (cd "$HOME/techstack" && python3 techstack.py "$u")
                else
                    echo "Invalid URL or Techstack not found."
                fi
                read -p "Press Enter to continue..."
                ;;
            12) 
                echo "Exiting CPA Control Center. Goodbye!"
                break 
                ;;
            *) 
                echo "Invalid choice. Please select a valid option."
                read -p "Press Enter to continue..."
                ;;
        esac
    else
        echo "Error: 'dialog' command not available. Please install 'dialog' package to use the dashboard menu."
        echo "You can still use the aliases: dashboard, loic, cpa, karma, tech."
        read -p "Press Enter to exit the dashboard script..."
        break
    fi
done
EOF

# Make the dashboard script executable.
chmod +x "$HOME/CPA-Dashboard.sh"
log "CPA Dashboard script created and made executable."

log "Setting up aliases in .zshrc..."
# Define an array of aliases.
declare -a ALIASES=(
    'alias dashboard="bash $HOME/CPA-Dashboard.sh"'
    'alias loic="cd $HOME/LOIC && ./LOIC"'
    'alias cpa="cd $HOME/cpa && ./main"'
    'alias karma="cd $HOME/karma-go && ./karma"'
    'alias tech="cd $HOME/techstack && python3 techstack.py"'
)

# Add aliases to .zshrc if they don't already exist.
for alias_cmd in "${ALIASES[@]}"; do
    if ! grep -q "$alias_cmd" "$HOME/.zshrc" 2>/dev/null; then
        echo "$alias_cmd" >> "$HOME/.zshrc"
        log "Alias added: $alias_cmd"
    else
        log "Alias already exists: $alias_cmd"
    fi
done

log "Setting up CPA banner in .zshrc..."
# Append the CPA banner logic to .zshrc.
cat << 'EOBANNER' >> "$HOME/.zshrc"

# CPA Banner - Displays on Zsh startup if figlet and lolcat are available.
if command -v figlet >/dev/null 2>&1 && command -v lolcat >/dev/null 2>&1; then
    clear
    # Get terminal width, default to 80 if tput fails.
    width=$(tput cols 2>/dev/null || echo 80)
    text="C P A"
    # Generate figlet banner, try 'slant' font first, then default.
    banner=$(figlet -f slant "$text" 2>/dev/null || figlet "$text" 2>/dev/null || echo "$text")
    
    # Print banner lines centered and colored with lolcat.
    while IFS= read -r line; do 
        printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"
    done <<< "$banner" | lolcat 2>/dev/null || {
        # Fallback if lolcat fails.
        while IFS= read -r line; do 
            printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"
        done <<< "$banner"
    }
    
    echo
    subtitle="Cyber People Attack"
    separator="==========================="
    
    # Print subtitle and separator centered and colored with lolcat, with fallback.
    printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle" | lolcat 2>/dev/null || printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle"
    printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator" | lolcat 2>/dev/null || printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator"
    echo
    
    # Simple initialization spinner.
    echo -n "Initializing "
    spinner="/-\|"
    for i in $(seq 1 4); do 
        for j in $(seq 0 3); do 
            printf "\b${spinner:$j:1}" # Print spinner character, then backspace.
            sleep 0.1
        done
    done
    echo -e "\b Ready! 🚀" # Backspace one last time and print " Ready! 🚀"
    echo
elif command -v figlet >/dev/null 2>&1; then
    # Fallback if only figlet is available (no lolcat).
    clear
    width=$(tput cols 2>/dev/null || echo 80)
    text="C P A"
    banner=$(figlet -f slant "$text" 2>/dev/null || figlet "$text" 2>/dev/null || echo "$text")
    
    while IFS= read -r line; do 
        printf "%*s\n" $(( (${#line} + width) / 2 )) "$line"
    done <<< "$banner"
    
    echo
    subtitle="Cyber People Attack"
    separator="==========================="
    printf "%*s\n" $(( (${#subtitle} + width) / 2 )) "$subtitle"
    printf "%*s\n" $(( (${#separator} + width) / 2 )) "$separator"
    echo
fi
EOBANNER
log "CPA banner added to .zshrc."

# Attempt to set zsh as the default shell.
if command_exists zsh; then
    log "Setting zsh as default shell..."
    if command_exists chsh; then
        # chsh might require password or root, so suppress errors and warn.
        if chsh -s "$(which zsh)" 2>/dev/null; then
            log "Default shell changed to zsh."
        else
            log "Warning: Could not change default shell to zsh. You may need to do it manually (e.g., 'chsh -s $(which zsh)')."
        fi
    else
        log "Warning: 'chsh' command not found. Cannot change default shell automatically."
    fi
else
    log "Warning: 'zsh' command not found. Cannot set zsh as default shell."
fi

clear
# Display final "CPA Ready" message.
if command_exists figlet && command_exists lolcat; then
    figlet "CPA Ready" | lolcat
elif command_exists figlet; then
    figlet "CPA Ready"
else
    echo "=========================================="
    echo "          CPA READY                     "
    echo "=========================================="
fi

log "Installation completed successfully!"
echo
echo "Available commands:"
echo "  dashboard   - Open CPA control center"
echo "  loic        - Launch LOIC"
echo "  cpa         - Launch CPA tool"
echo "  karma       - Launch Karma-Go"
echo "  tech        - Launch Techstack"
echo
echo "To start using CPA, run: source ~/.zshrc && dashboard"
echo "You may need to restart your Termux session for all changes to take effect."

