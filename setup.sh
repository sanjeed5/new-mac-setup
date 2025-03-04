#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# Print security warning
print_security_warning() {
    echo -e "${PURPLE}⚠️  SECURITY WARNING: $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Welcome message
clear
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  Mac Development Setup Script   ${NC}"
echo -e "${GREEN}=================================${NC}"
echo
echo "This script will help you set up your new Mac for development."
echo "You can choose which components to install."
echo

# Create necessary directories
mkdir -p scripts

# Check if running for the first time and create script files
if [ ! -f scripts/install_homebrew.sh ]; then
    print_info "First run detected. Creating script files..."
    
    # Create individual script files (they will be populated later)
    touch scripts/install_homebrew.sh
    touch scripts/install_brew_packages.sh
    touch scripts/setup_shell.sh
    touch scripts/setup_git.sh
    touch scripts/setup_node.sh
    touch scripts/setup_python.sh
    touch scripts/setup_macos_preferences.sh
    
    # Make all scripts executable
    chmod +x scripts/*.sh
fi

# === CORE DEVELOPMENT TOOLS ===
print_header "CORE DEVELOPMENT TOOLS"
echo "These are essential tools for development:"

if confirm "Install Homebrew? (package manager for macOS)"; then
    source ./scripts/install_homebrew.sh
fi

if confirm "Install packages from Brewfile? (common development tools)"; then
    source ./scripts/install_brew_packages.sh
fi

# === SHELL AND ENVIRONMENT SETUP ===
print_header "SHELL AND ENVIRONMENT SETUP"
echo "Configure your shell environment:"

if confirm "Set up shell? (Oh My Zsh, plugins, themes)"; then
    source ./scripts/setup_shell.sh
fi

if confirm "Set up Node.js? (nvm, npm global packages)"; then
    source ./scripts/setup_node.sh
fi

if confirm "Set up Python? (pyenv, virtualenv, etc.)"; then
    source ./scripts/setup_python.sh
fi

# === CONFIGURATION AND PREFERENCES ===
print_header "CONFIGURATION AND PREFERENCES"
echo "Configure your development environment:"

if confirm "Configure Git? (Note: will ask for your name and email)"; then
    print_info "Git configuration will ask for your name and email."
    source ./scripts/setup_git.sh
fi

if confirm "Configure macOS preferences? (development-focused settings)"; then
    source ./scripts/setup_macos_preferences.sh
fi

# === RESTORE FROM BACKUP ===
print_header "RESTORE FROM BACKUP"
echo "Restore settings from backup (if available):"

# Check for public backups
if [ -d "backups/public" ] && [ "$(ls -A backups/public 2>/dev/null)" ]; then
    print_info "Public backups found."
    if confirm "Restore public settings from backup?"; then
        source ./scripts/restore_public_settings.sh
    fi
else
    print_info "No public backups found. Skipping restore."
fi

# Check for private backups with security warning
if [ -d "backups/private" ] && [ "$(ls -A backups/private 2>/dev/null)" ]; then
    print_info "Private backups found."
    print_security_warning "Private backups may contain sensitive information."
    if confirm "Restore private settings from backup?"; then
        source ./scripts/restore_private_settings.sh
    fi
else
    print_info "No private backups found. Skipping restore."
fi

print_header "Setup Complete!"
echo "Your Mac has been set up according to your preferences."
echo "If you encounter any issues, please check the individual script files in the 'scripts' directory."
echo
echo "Happy coding! 🚀"
echo
echo "Note: To backup your settings, run the backup.sh script." 