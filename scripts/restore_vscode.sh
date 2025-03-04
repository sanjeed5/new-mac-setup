#!/bin/bash

print_header "Restoring VSCode Settings"

# Check if VSCode is installed
if ! command_exists code; then
    print_error "VSCode is not installed. Please install VSCode first."
    exit 1
fi

# Create VSCode directories if they don't exist
vscode_dir="$HOME/Library/Application Support/Code/User"
mkdir -p "$vscode_dir"

# Check if backup exists
if [ ! -d "backups/vscode" ]; then
    print_error "VSCode backup not found at backups/vscode"
    exit 1
fi

# Restore settings.json
if [ -f "backups/vscode/settings.json" ]; then
    print_info "Restoring settings.json..."
    cp "backups/vscode/settings.json" "$vscode_dir/"
    print_success "Restored settings.json"
fi

# Restore keybindings.json
if [ -f "backups/vscode/keybindings.json" ]; then
    print_info "Restoring keybindings.json..."
    cp "backups/vscode/keybindings.json" "$vscode_dir/"
    print_success "Restored keybindings.json"
fi

# Restore snippets
if [ -d "backups/vscode/snippets" ]; then
    print_info "Restoring code snippets..."
    mkdir -p "$vscode_dir/snippets"
    cp -R "backups/vscode/snippets/"* "$vscode_dir/snippets/"
    print_success "Restored code snippets"
fi

# Install extensions
if [ -f "backups/vscode/extensions.txt" ]; then
    print_info "Installing VSCode extensions..."
    while read extension; do
        if [ ! -z "$extension" ]; then
            print_info "Installing extension: $extension"
            code --install-extension "$extension"
        fi
    done < "backups/vscode/extensions.txt"
    print_success "VSCode extensions installed"
fi

print_success "VSCode settings restoration completed!" 