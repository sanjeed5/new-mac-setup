#!/bin/bash

print_header "Installing Packages from Brewfile"

# Check if Homebrew is installed
if ! command_exists brew; then
    print_error "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Check if Brewfile exists
if [ ! -f "Brewfile" ]; then
    print_error "Brewfile not found in the current directory."
    
    # Ask if user wants to create a new Brewfile
    if confirm "Do you want to create a new Brewfile?"; then
        print_info "Creating a new Brewfile..."
        touch Brewfile
        print_success "Empty Brewfile created. You can edit it later."
    else
        exit 1
    fi
fi

# Ask if user wants to edit the Brewfile before installation
if confirm "Do you want to review/edit the Brewfile before installation?"; then
    # Determine which editor to use
    if [ -n "$EDITOR" ]; then
        $EDITOR Brewfile
    elif command_exists nano; then
        nano Brewfile
    elif command_exists vim; then
        vim Brewfile
    else
        print_error "No editor found. Please edit the Brewfile manually."
    fi
fi

# Install packages from Brewfile
print_info "Installing packages from Brewfile..."
brew bundle

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