#!/bin/bash

print_header "Installing Packages from Brewfile"

# Check if Homebrew is installed
if ! command_exists brew; then
    print_error "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Check if Brewfile exists in backup location
if [ -f "backups/homebrew/Brewfile" ]; then
    BREWFILE_PATH="backups/homebrew/Brewfile"
elif [ -f "Brewfile" ]; then
    BREWFILE_PATH="Brewfile"
else
    print_error "Brewfile not found in backups/homebrew/ or current directory."
    
    # Ask if user wants to create a new Brewfile
    if confirm "Do you want to create a new Brewfile?"; then
        print_info "Creating a new Brewfile..."
        mkdir -p backups/homebrew
        BREWFILE_PATH="backups/homebrew/Brewfile"
        touch "$BREWFILE_PATH"
        print_success "Empty Brewfile created at $BREWFILE_PATH. You can edit it later."
    else
        exit 1
    fi
fi

# Ask if user wants to edit the Brewfile before installation
if confirm "Do you want to review/edit the Brewfile before installation?"; then
    # Determine which editor to use
    if [ -n "$EDITOR" ]; then
        $EDITOR "$BREWFILE_PATH"
    elif command_exists nano; then
        nano "$BREWFILE_PATH"
    elif command_exists vim; then
        vim "$BREWFILE_PATH"
    else
        print_error "No editor found. Please edit the Brewfile manually."
    fi
fi

# Install packages from Brewfile
print_info "Installing packages from Brewfile..."
brew bundle --file="$BREWFILE_PATH"

if [ $? -eq 0 ]; then
    print_success "All packages from Brewfile installed successfully."
else
    print_error "Some packages failed to install. Check the output above for details."
fi

# Cleanup
if confirm "Do you want to clean up (remove outdated packages)?"; then
    print_info "Cleaning up..."
    brew cleanup
    print_success "Cleanup completed."
fi 