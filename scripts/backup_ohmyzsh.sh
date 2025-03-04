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

print_header "Backing Up Oh My Zsh Configuration"

# Create necessary directories
mkdir -p backups/ohmyzsh/custom/themes
mkdir -p backups/ohmyzsh/custom/plugins

# Backup .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" backups/ohmyzsh/
    print_success "Backed up .zshrc"
else
    print_error ".zshrc not found"
fi

# Backup .p10k.zsh if it exists
if [ -f "$HOME/.p10k.zsh" ]; then
    cp "$HOME/.p10k.zsh" backups/ohmyzsh/
    print_success "Backed up .p10k.zsh"
else
    print_info ".p10k.zsh not found, skipping"
fi

# Backup custom themes
print_info "Backing up custom themes..."
if [ -d "$HOME/.oh-my-zsh/custom/themes" ]; then
    # Only copy custom themes (not the default ones or powerlevel10k which will be installed fresh)
    find "$HOME/.oh-my-zsh/custom/themes" -maxdepth 1 -type f -not -path "*/\.*" -exec cp {} backups/ohmyzsh/custom/themes/ \;
    
    # Check if there are any custom themes that are directories (except powerlevel10k which we'll install fresh)
    for theme_dir in "$HOME/.oh-my-zsh/custom/themes"/*/; do
        theme_name=$(basename "$theme_dir")
        if [ "$theme_name" != "powerlevel10k" ] && [ "$theme_name" != "." ] && [ "$theme_name" != ".." ]; then
            mkdir -p "backups/ohmyzsh/custom/themes/$theme_name"
            cp -R "$theme_dir"* "backups/ohmyzsh/custom/themes/$theme_name/"
            print_success "Backed up custom theme: $theme_name"
        fi
    done
else
    print_info "No custom themes directory found, skipping"
fi

# Backup custom plugins
print_info "Backing up custom plugins..."
if [ -d "$HOME/.oh-my-zsh/custom/plugins" ]; then
    # Skip standard plugins that will be installed fresh (zsh-syntax-highlighting, zsh-autosuggestions)
    for plugin_dir in "$HOME/.oh-my-zsh/custom/plugins"/*/; do
        plugin_name=$(basename "$plugin_dir")
        if [ "$plugin_name" != "zsh-syntax-highlighting" ] && [ "$plugin_name" != "zsh-autosuggestions" ] && [ "$plugin_name" != "." ] && [ "$plugin_name" != ".." ]; then
            mkdir -p "backups/ohmyzsh/custom/plugins/$plugin_name"
            cp -R "$plugin_dir"* "backups/ohmyzsh/custom/plugins/$plugin_name/"
            print_success "Backed up custom plugin: $plugin_name"
        fi
    done
else
    print_info "No custom plugins directory found, skipping"
fi

# Backup custom aliases or functions if they exist
if [ -d "$HOME/.oh-my-zsh/custom" ]; then
    mkdir -p backups/ohmyzsh/custom
    find "$HOME/.oh-my-zsh/custom" -maxdepth 1 -type f -name "*.zsh" -exec cp {} backups/ohmyzsh/custom/ \;
    for file in backups/ohmyzsh/custom/*.zsh; do
        if [ -f "$file" ]; then
            print_success "Backed up custom file: $(basename "$file")"
        fi
    done
fi

print_success "Oh My Zsh configuration backup completed!"
print_info "Your Oh My Zsh configuration has been backed up to the backups/ohmyzsh directory."
print_info "You can now commit these files to your Git repository." 