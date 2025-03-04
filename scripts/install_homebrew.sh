#!/bin/bash

# Install Homebrew if not already installed
print_header "Installing Homebrew"

if command_exists brew; then
    print_success "Homebrew is already installed."
    
    # Update Homebrew
    print_info "Updating Homebrew..."
    brew update
    print_success "Homebrew updated successfully."
else
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Add Homebrew to PATH for Apple Silicon Macs
    if [[ $(uname -m) == 'arm64' ]]; then
        print_info "Configuring Homebrew for Apple Silicon..."
        
        # Check which shell is being used
        if [[ $SHELL == *"zsh"* ]]; then
            if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.zprofile; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        elif [[ $SHELL == *"bash"* ]]; then
            if ! grep -q 'eval "$(/opt/homebrew/bin/brew shellenv)"' ~/.bash_profile; then
                echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.bash_profile
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi
        fi
    fi
    
    print_success "Homebrew installed successfully."
fi

# Install Homebrew Bundle if not already installed
if ! brew list --formula | grep -q "^brew-bundle$"; then
    print_info "Installing Homebrew Bundle..."
    brew tap Homebrew/bundle
    print_success "Homebrew Bundle installed successfully."
else
    print_success "Homebrew Bundle is already installed."
fi 