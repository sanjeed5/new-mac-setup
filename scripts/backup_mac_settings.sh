#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Print section header
print_header() {
    echo -e "\n${BLUE}==== $1 ====${NC}\n"
}

# Print success message
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Print error message
print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Print info message
print_info() {
    echo -e "${YELLOW}ℹ $1${NC}"
}

# Ask for confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

print_header "Backing Up Mac Settings and Configurations"

# Security warning
echo -e "${RED}==================================================${NC}"
echo -e "${RED}  SECURITY WARNING - READ BEFORE PROCEEDING      ${NC}"
echo -e "${RED}==================================================${NC}"
echo -e "${YELLOW}This script will backup your Mac settings and configurations.${NC}"
echo -e "${YELLOW}Some of these settings may contain sensitive information.${NC}"
echo -e "${YELLOW}NEVER commit sensitive information to a public repository:${NC}"
echo -e "${RED}- Private SSH keys${NC}"
echo -e "${RED}- API tokens or passwords${NC}"
echo -e "${RED}- Personal credentials${NC}"
echo -e "${RED}- Database connection strings${NC}"
echo
if ! confirm "I understand the security risks and will not commit sensitive information to a public repository"; then
    print_error "Backup aborted due to security concerns"
    exit 1
fi

# Create backup directory
backup_dir="config/mac_backup"
mkdir -p "$backup_dir"

# Backup SSH keys and config
print_info "Backing up SSH configuration..."
mkdir -p "$backup_dir/ssh"
if [ -d "$HOME/.ssh" ]; then
    # Only copy config file and public keys by default (for safety)
    cp "$HOME/.ssh/config" "$backup_dir/ssh/config" 2>/dev/null || true
    cp "$HOME/.ssh/"*.pub "$backup_dir/ssh/" 2>/dev/null || true
    print_success "SSH public keys and config backed up"
    
    # Create example files for private keys instead of backing up actual keys
    echo "# This is an example file. NEVER commit actual private keys to a repository." > "$backup_dir/ssh/id_rsa.example"
    echo "# Instead, generate your own keys and keep them secure." >> "$backup_dir/ssh/id_rsa.example"
    
    # Ask if user wants to backup private keys (with stronger warning)
    echo
    echo -e "${RED}==================================================${NC}"
    echo -e "${RED}  DANGER: PRIVATE KEY BACKUP - HIGH SECURITY RISK ${NC}"
    echo -e "${RED}==================================================${NC}"
    echo -e "${YELLOW}Backing up private SSH keys is a significant security risk.${NC}"
    echo -e "${YELLOW}These keys provide access to your accounts and should NEVER be:${NC}"
    echo -e "${RED}- Committed to ANY repository (public or private)${NC}"
    echo -e "${RED}- Shared with anyone${NC}"
    echo -e "${RED}- Stored in unsecured locations${NC}"
    echo
    echo -e "${YELLOW}Instead, consider:${NC}"
    echo -e "${GREEN}- Creating new keys for each machine${NC}"
    echo -e "${GREEN}- Using a password manager for backup${NC}"
    echo -e "${GREEN}- Using hardware security keys${NC}"
    echo
    
    if confirm "Despite these risks, do you still want to backup private SSH keys? (NOT RECOMMENDED)"; then
        # Create a secure local backup directory outside the repository
        secure_backup_dir="$HOME/secure_backups/ssh"
        mkdir -p "$secure_backup_dir"
        cp "$HOME/.ssh/id_"* "$secure_backup_dir/" 2>/dev/null || true
        chmod 700 "$secure_backup_dir"
        print_success "SSH private keys backed up to $secure_backup_dir (NOT in the repository)"
        print_info "IMPORTANT: This location is NOT in the Git repository for your security."
    fi
else
    print_info "No SSH directory found, skipping"
fi

# Backup Git global configuration
print_info "Backing up Git configuration..."
mkdir -p "$backup_dir/git"
if [ -f "$HOME/.gitconfig" ]; then
    cp "$HOME/.gitconfig" "$backup_dir/git/"
    print_success "Git global config backed up"
fi
if [ -f "$HOME/.gitignore_global" ]; then
    cp "$HOME/.gitignore_global" "$backup_dir/git/"
    print_success "Git global ignore file backed up"
fi

# Backup VSCode settings and extensions
print_info "Backing up VSCode configuration..."
mkdir -p "$backup_dir/vscode"
if [ -d "$HOME/Library/Application Support/Code/User" ]; then
    cp "$HOME/Library/Application Support/Code/User/settings.json" "$backup_dir/vscode/" 2>/dev/null || true
    cp "$HOME/Library/Application Support/Code/User/keybindings.json" "$backup_dir/vscode/" 2>/dev/null || true
    cp "$HOME/Library/Application Support/Code/User/snippets/"* "$backup_dir/vscode/snippets/" 2>/dev/null || true
    print_success "VSCode settings backed up"
    
    # Export list of installed extensions
    if command -v code >/dev/null 2>&1; then
        code --list-extensions > "$backup_dir/vscode/extensions.txt"
        print_success "VSCode extensions list backed up"
    else
        print_info "VSCode CLI not found, skipping extensions backup"
    fi
else
    print_info "VSCode user settings not found, skipping"
fi

# Backup JetBrains IDE settings
print_info "Backing up JetBrains IDE settings..."
mkdir -p "$backup_dir/jetbrains"
jetbrains_dir="$HOME/Library/Application Support/JetBrains"
if [ -d "$jetbrains_dir" ]; then
    # Just backup keymaps and templates which are smaller and don't contain sensitive info
    find "$jetbrains_dir" -path "*/keymaps/*" -exec cp --parents {} "$backup_dir/jetbrains/" \; 2>/dev/null || true
    find "$jetbrains_dir" -path "*/templates/*" -exec cp --parents {} "$backup_dir/jetbrains/" \; 2>/dev/null || true
    print_success "JetBrains IDE settings backed up"
else
    print_info "JetBrains IDE settings not found, skipping"
fi

# Backup Homebrew packages
print_info "Backing up Homebrew packages list..."
if command -v brew >/dev/null 2>&1; then
    brew bundle dump --file="$backup_dir/Brewfile" --force
    print_success "Homebrew packages backed up to Brewfile"
else
    print_info "Homebrew not found, skipping"
fi

# Backup npm global packages
print_info "Backing up npm global packages..."
if command -v npm >/dev/null 2>&1; then
    npm list -g --depth=0 > "$backup_dir/npm_global_packages.txt"
    print_success "npm global packages list backed up"
else
    print_info "npm not found, skipping"
fi

# Backup pnpm global packages
print_info "Backing up pnpm global packages..."
if command -v pnpm >/dev/null 2>&1; then
    pnpm list -g > "$backup_dir/pnpm_global_packages.txt" 2>/dev/null || true
    print_success "pnpm global packages list backed up"
else
    print_info "pnpm not found, skipping"
fi

# Backup Python packages
print_info "Backing up Python packages..."
if command -v pip >/dev/null 2>&1; then
    pip list > "$backup_dir/pip_packages.txt"
    print_success "pip packages list backed up"
else
    print_info "pip not found, skipping"
fi

# Backup pyenv Python versions
print_info "Backing up pyenv Python versions..."
if command -v pyenv >/dev/null 2>&1; then
    pyenv versions > "$backup_dir/pyenv_versions.txt"
    print_success "pyenv versions backed up"
else
    print_info "pyenv not found, skipping"
fi

# Backup nvm Node.js versions
print_info "Backing up nvm Node.js versions..."
if [ -d "$HOME/.nvm" ]; then
    if command -v nvm >/dev/null 2>&1; then
        nvm ls > "$backup_dir/nvm_versions.txt" 2>/dev/null || true
        print_success "nvm versions backed up"
    else
        ls -la "$HOME/.nvm/versions/node" > "$backup_dir/nvm_versions.txt" 2>/dev/null || true
        print_success "nvm versions directory listing backed up"
    fi
else
    print_info "nvm not found, skipping"
fi

# Backup shell aliases and functions
print_info "Backing up shell configuration files..."
mkdir -p "$backup_dir/shell"
for file in ".zshrc" ".bashrc" ".bash_profile" ".profile" ".zprofile"; do
    if [ -f "$HOME/$file" ]; then
        cp "$HOME/$file" "$backup_dir/shell/"
        print_success "Backed up $file"
    fi
done

# Backup custom shell scripts
print_info "Backing up custom shell scripts..."
if [ -d "$HOME/bin" ]; then
    mkdir -p "$backup_dir/bin"
    cp -R "$HOME/bin/"* "$backup_dir/bin/" 2>/dev/null || true
    print_success "Custom scripts in ~/bin backed up"
fi

# Backup macOS preferences
print_info "Backing up macOS preferences..."
mkdir -p "$backup_dir/macos"

# Export Dock configuration
defaults export com.apple.dock "$backup_dir/macos/dock.plist" 2>/dev/null || true
print_success "Dock preferences backed up"

# Export Finder configuration
defaults export com.apple.finder "$backup_dir/macos/finder.plist" 2>/dev/null || true
print_success "Finder preferences backed up"

# Export Terminal configuration
defaults export com.apple.Terminal "$backup_dir/macos/terminal.plist" 2>/dev/null || true
print_success "Terminal preferences backed up"

# Export iTerm2 configuration
if [ -f "$HOME/Library/Preferences/com.googlecode.iterm2.plist" ]; then
    cp "$HOME/Library/Preferences/com.googlecode.iterm2.plist" "$backup_dir/macos/" 2>/dev/null || true
    print_success "iTerm2 preferences backed up"
fi

# Export mouse/trackpad settings
defaults export com.apple.driver.AppleBluetoothMultitouch.mouse "$backup_dir/macos/mouse.plist" 2>/dev/null || true
defaults export com.apple.driver.AppleBluetoothMultitouch.trackpad "$backup_dir/macos/trackpad.plist" 2>/dev/null || true
defaults export com.apple.AppleMultitouchTrackpad "$backup_dir/macos/apple_trackpad.plist" 2>/dev/null || true
print_success "Mouse and trackpad preferences backed up"

# Export keyboard settings
defaults export com.apple.keyboard "$backup_dir/macos/keyboard.plist" 2>/dev/null || true
defaults export com.apple.HIToolbox "$backup_dir/macos/input_sources.plist" 2>/dev/null || true
print_success "Keyboard preferences backed up"

# Export display settings
defaults export com.apple.displays "$backup_dir/macos/displays.plist" 2>/dev/null || true
print_success "Display preferences backed up"

# Export sound settings
defaults export com.apple.sound "$backup_dir/macos/sound.plist" 2>/dev/null || true
print_success "Sound preferences backed up"

# Export accessibility settings
defaults export com.apple.universalaccess "$backup_dir/macos/accessibility.plist" 2>/dev/null || true
print_success "Accessibility preferences backed up"

# Export system preferences
defaults export com.apple.systempreferences "$backup_dir/macos/systempreferences.plist" 2>/dev/null || true
print_success "System preferences backed up"

# Export additional global system settings
mkdir -p "$backup_dir/macos/global_domain"
defaults export -g "$backup_dir/macos/global_domain/global_domain.plist" 2>/dev/null || true
print_success "Global system preferences backed up"

# Backup hosts file
if [ -f "/etc/hosts" ]; then
    sudo cp "/etc/hosts" "$backup_dir/macos/" 2>/dev/null || true
    print_success "Hosts file backed up"
fi

# Backup browser bookmarks (if user wants to)
if confirm "Do you want to backup browser bookmarks?"; then
    mkdir -p "$backup_dir/browsers"
    
    # Chrome bookmarks
    chrome_bookmarks="$HOME/Library/Application Support/Google/Chrome/Default/Bookmarks"
    if [ -f "$chrome_bookmarks" ]; then
        cp "$chrome_bookmarks" "$backup_dir/browsers/chrome_bookmarks"
        print_success "Chrome bookmarks backed up"
    fi
    
    # Safari bookmarks
    safari_bookmarks="$HOME/Library/Safari/Bookmarks.plist"
    if [ -f "$safari_bookmarks" ]; then
        cp "$safari_bookmarks" "$backup_dir/browsers/safari_bookmarks.plist"
        print_success "Safari bookmarks backed up"
    fi
    
    # Firefox bookmarks (more complex, just note the location)
    print_info "Firefox bookmarks are in: $HOME/Library/Application Support/Firefox/Profiles/*/places.sqlite"
    print_info "You may want to manually export them from Firefox's bookmark manager"
fi

# Backup database configurations
print_info "Backing up database configurations..."
mkdir -p "$backup_dir/databases"

# MySQL
if [ -f "$HOME/.my.cnf" ]; then
    cp "$HOME/.my.cnf" "$backup_dir/databases/"
    print_success "MySQL configuration backed up"
fi

# PostgreSQL
if [ -f "$HOME/.psqlrc" ]; then
    cp "$HOME/.psqlrc" "$backup_dir/databases/"
    print_success "PostgreSQL configuration backed up"
fi

# MongoDB
if [ -f "$HOME/.mongorc.js" ]; then
    cp "$HOME/.mongorc.js" "$backup_dir/databases/"
    print_success "MongoDB configuration backed up"
fi

# Backup Docker configurations
print_info "Backing up Docker configurations..."
if [ -d "$HOME/.docker" ]; then
    mkdir -p "$backup_dir/docker"
    cp "$HOME/.docker/config.json" "$backup_dir/docker/" 2>/dev/null || true
    print_success "Docker configuration backed up"
fi

# Backup Kubernetes configurations
print_info "Backing up Kubernetes configurations..."
if [ -d "$HOME/.kube" ]; then
    mkdir -p "$backup_dir/kubernetes"
    cp -R "$HOME/.kube/config" "$backup_dir/kubernetes/" 2>/dev/null || true
    print_success "Kubernetes configuration backed up"
fi

# Backup AWS configurations
print_info "Backing up AWS configurations..."
if [ -d "$HOME/.aws" ]; then
    mkdir -p "$backup_dir/aws"
    cp "$HOME/.aws/config" "$backup_dir/aws/" 2>/dev/null || true
    # Don't backup credentials by default for security
    if confirm "Do you want to backup AWS credentials? (SECURITY WARNING: Contains sensitive information)"; then
        cp "$HOME/.aws/credentials" "$backup_dir/aws/" 2>/dev/null || true
        print_success "AWS credentials backed up"
        print_info "IMPORTANT: Keep these credentials secure and never commit them to a public repository!"
    fi
    print_success "AWS configuration backed up"
fi

# Backup Obsidian vaults list (if installed)
print_info "Backing up Obsidian configuration..."
obsidian_dir="$HOME/Library/Application Support/obsidian"
if [ -d "$obsidian_dir" ]; then
    mkdir -p "$backup_dir/obsidian"
    cp "$obsidian_dir/obsidian.json" "$backup_dir/obsidian/" 2>/dev/null || true
    print_success "Obsidian configuration backed up"
    print_info "Note: Obsidian vault contents are not backed up, only the configuration"
fi

# Backup Raycast settings (if installed)
print_info "Backing up Raycast configuration..."
raycast_dir="$HOME/Library/Application Support/com.raycast.macos"
mkdir -p "$backup_dir/raycast"

# Check if Raycast is installed
if [ -d "$raycast_dir" ]; then
    # Copy Raycast preferences
    cp -R "$raycast_dir/preferences.json" "$backup_dir/raycast/" 2>/dev/null || true
    # Copy extensions data
    cp -R "$raycast_dir/extensions-data" "$backup_dir/raycast/" 2>/dev/null || true
    # Copy installed extensions list
    cp -R "$raycast_dir/extensions.json" "$backup_dir/raycast/" 2>/dev/null || true
    print_success "Raycast configuration backed up"
    print_info "Note: You can also export Raycast settings directly from the app (Preferences > Advanced)"
else
    print_info "Raycast not found, skipping automatic backup"
fi

# Check for manually exported Raycast settings
if [ -d "config/raycast" ]; then
    # Check if there are any exported settings files (*.rayconfig)
    rayconfig_files=$(find "config/raycast" -name "*.rayconfig" 2>/dev/null)
    if [ -n "$rayconfig_files" ]; then
        # Copy any manually exported Raycast settings files
        cp -R config/raycast/*.rayconfig "$backup_dir/raycast/" 2>/dev/null || true
        print_success "Manually exported Raycast settings found and backed up"
        print_info "These will be available for manual import on your new Mac"
    fi
fi

# Backup application licenses
print_info "Note: Application licenses should be backed up manually."
print_info "Common locations include:"
print_info "- Email (search for 'license' or 'purchase')"
print_info "- Documents folder"
print_info "- Application-specific folders in ~/Library/Application Support/"

# Create a README file with instructions
cat > "$backup_dir/README.md" << 'EOL'
# Mac Backup

This directory contains backed up settings and configurations from your Mac.

## Contents

- `ssh/`: SSH keys and configuration
- `git/`: Git global configuration
- `vscode/`: Visual Studio Code settings and extensions list
- `jetbrains/`: JetBrains IDE settings (keymaps and templates)
- `Brewfile`: Homebrew packages, casks, and taps
- `npm_global_packages.txt`: List of globally installed npm packages
- `pnpm_global_packages.txt`: List of globally installed pnpm packages
- `pip_packages.txt`: List of installed Python packages
- `pyenv_versions.txt`: List of installed Python versions via pyenv
- `nvm_versions.txt`: List of installed Node.js versions via nvm
- `shell/`: Shell configuration files
- `bin/`: Custom shell scripts from ~/bin
- `macos/`: macOS preferences including:
  - Dock, Finder, Terminal settings
  - Mouse and trackpad settings
  - Keyboard settings and input sources
  - Display settings
  - Sound settings
  - Accessibility options
  - Global system preferences
- `browsers/`: Browser bookmarks and settings
- `databases/`: Database client configurations
- `docker/`: Docker configuration
- `kubernetes/`: Kubernetes configuration
- `aws/`: AWS configuration
- `obsidian/`: Obsidian configuration
- `raycast/`: Raycast configuration

## Restoring

Most of these files can be restored by copying them to their original locations on your new Mac.
The setup scripts in this repository will handle many of these automatically.

For manual restoration:
- SSH: Copy to `~/.ssh/` (set appropriate permissions with `chmod 600`)
- Git: Copy to `~/`
- VSCode: Copy to `~/Library/Application Support/Code/User/`
- Homebrew: Use `brew bundle install --file=Brewfile`
- npm: Install packages listed in npm_global_packages.txt
- pnpm: Install packages listed in pnpm_global_packages.txt
- pip: Install packages listed in pip_packages.txt
- pyenv: Install Python versions listed in pyenv_versions.txt
- nvm: Install Node.js versions listed in nvm_versions.txt
- Shell: Copy to `~/`
- macOS: Import preferences with `defaults import domain path/to/file.plist`
  - For example: `defaults import com.apple.dock path/to/dock.plist`
  - For mouse settings: `defaults import com.apple.driver.AppleBluetoothMultitouch.mouse path/to/mouse.plist`
  - For trackpad settings: `defaults import com.apple.driver.AppleBluetoothMultitouch.trackpad path/to/trackpad.plist`
  - For global settings: `defaults import -g path/to/global_domain.plist`
  - Note: You may need to restart or log out/in for some settings to take effect
- Databases: Copy to `~/`
- Docker: Copy to `~/.docker/`
- Kubernetes: Copy to `~/.kube/`
- AWS: Copy to `~/.aws/`
- Obsidian: Copy to `~/Library/Application Support/obsidian/`
- Raycast: Copy to `~/Library/Application Support/com.raycast.macos/`

## Security Warning

Some of these files may contain sensitive information. Review them carefully before committing to a public repository.
Consider using a private repository or encrypting sensitive files.
EOL

print_success "Mac settings backup completed!"
print_info "Your Mac settings have been backed up to the $backup_dir directory."
print_info "You can now commit these files to your Git repository."
print_info "IMPORTANT: Review the backed up files before committing to ensure no sensitive information is included." 