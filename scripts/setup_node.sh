#!/bin/bash

print_header "Setting Up Node.js Environment"

# Check if Node.js is already installed via Homebrew
if command_exists node && command_exists brew && brew list | grep -q "^node$"; then
    print_info "Node.js is already installed via Homebrew."
    node_version=$(node -v)
    print_info "Current Node.js version: $node_version"
    
    if confirm "Do you want to continue with the Homebrew version of Node.js?"; then
        print_info "Continuing with Homebrew version of Node.js."
    else
        print_info "We'll install nvm for better Node.js version management."
        if confirm "Do you want to uninstall the Homebrew version of Node.js?"; then
            print_info "Uninstalling Homebrew Node.js..."
            brew uninstall node
            print_success "Homebrew Node.js uninstalled."
        else
            print_info "Keeping Homebrew Node.js alongside nvm."
        fi
    fi
fi

# Install nvm (Node Version Manager)
if [ ! -d "$HOME/.nvm" ]; then
    print_info "Installing nvm (Node Version Manager)..."
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    if command_exists nvm; then
        print_success "nvm installed successfully."
    else
        print_error "Failed to install nvm. Please check the output above for details."
        exit 1
    fi
else
    print_success "nvm is already installed."
    
    # Source nvm
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    
    # Update nvm
    print_info "Updating nvm..."
    (
        cd "$NVM_DIR"
        git fetch --tags origin
        git checkout `git describe --abbrev=0 --tags --match "v[0-9]*" $(git rev-list --tags --max-count=1)`
    ) && \. "$NVM_DIR/nvm.sh"
    print_success "nvm updated successfully."
fi

# Install Node.js LTS version
if command_exists nvm; then
    if confirm "Do you want to install the latest LTS version of Node.js?"; then
        print_info "Installing Node.js LTS version..."
        nvm install --lts
        nvm use --lts
        nvm alias default node
        
        node_version=$(node -v)
        print_success "Node.js LTS version $node_version installed and set as default."
    fi
    
    # Ask if user wants to install additional Node.js versions
    if confirm "Do you want to install additional Node.js versions?"; then
        read -p "Enter Node.js versions to install (e.g., 14.17.0 16.13.0): " node_versions
        
        for version in $node_versions; do
            print_info "Installing Node.js version $version..."
            nvm install $version
            print_success "Node.js version $version installed."
        done
    fi
else
    print_error "nvm is not available. Skipping Node.js installation."
fi

# Install pnpm
if command_exists npm; then
    if ! command_exists pnpm; then
        print_info "Installing pnpm..."
        
        # Check if Homebrew is installed
        if command_exists brew; then
            brew install pnpm
        else
            npm install -g pnpm
        fi
        
        if [ $? -eq 0 ]; then
            print_success "pnpm installed successfully."
            
            # Configure pnpm
            print_info "Configuring pnpm..."
            
            # Add pnpm to shell configuration
            if [[ $SHELL == *"zsh"* ]]; then
                if ! grep -q 'export PNPM_HOME' ~/.zshrc; then
                    echo '# pnpm configuration' >> ~/.zshrc
                    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.zshrc
                    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.zshrc
                    echo 'alias npm="pnpm"' >> ~/.zshrc
                fi
            elif [[ $SHELL == *"bash"* ]]; then
                if ! grep -q 'export PNPM_HOME' ~/.bashrc; then
                    echo '# pnpm configuration' >> ~/.bashrc
                    echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> ~/.bashrc
                    echo 'export PATH="$PNPM_HOME:$PATH"' >> ~/.bashrc
                    echo 'alias npm="pnpm"' >> ~/.bashrc
                fi
            fi
            
            # Initialize pnpm
            export PNPM_HOME="$HOME/.local/share/pnpm"
            export PATH="$PNPM_HOME:$PATH"
            
            print_success "pnpm configured."
        else
            print_error "Failed to install pnpm."
        fi
    else
        print_success "pnpm is already installed."
    fi
    
    # Determine which package manager to use
    PACKAGE_MANAGER="npm"
    if command_exists pnpm; then
        PACKAGE_MANAGER="pnpm"
    fi
    
    # Install global npm packages
    if confirm "Do you want to install common global npm packages?"; then
        print_info "Installing global npm packages..."
        
        # List of common global npm packages
        packages=(
            "npm"
            "yarn"
            "typescript"
            "ts-node"
            "nodemon"
            "eslint"
            "prettier"
            "serve"
            "http-server"
            "create-react-app"
            "next"
            "gatsby-cli"
            "vue-cli"
            "express-generator"
            "npm-check-updates"
        )
        
        echo "Available packages to install:"
        for i in "${!packages[@]}"; do
            echo "$((i+1)). ${packages[$i]}"
        done
        
        read -p "Enter package numbers to install (e.g., 1 2 3) or 'all' for all packages: " package_selection
        
        if [ "$package_selection" = "all" ]; then
            for package in "${packages[@]}"; do
                print_info "Installing $package..."
                $PACKAGE_MANAGER add -g $package
                print_success "$package installed globally."
            done
        else
            for num in $package_selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#packages[@]} ]; then
                    package=${packages[$((num-1))]}
                    print_info "Installing $package..."
                    $PACKAGE_MANAGER add -g $package
                    print_success "$package installed globally."
                else
                    print_error "Invalid selection: $num. Skipping."
                fi
            done
        fi
    fi
    
    # Ask if user wants to install custom global npm packages
    if confirm "Do you want to install custom global npm packages?"; then
        read -p "Enter npm packages to install globally (space-separated): " custom_packages
        
        for package in $custom_packages; do
            print_info "Installing $package..."
            $PACKAGE_MANAGER add -g $package
            
            if [ $? -eq 0 ]; then
                print_success "$package installed globally."
            else
                print_error "Failed to install $package. Please check the output above for details."
            fi
        done
    fi
    
    # Configure npm defaults
    if confirm "Do you want to configure npm defaults for new projects?"; then
        print_info "Configuring npm defaults..."
        
        # Set npm init defaults
        read -p "Enter default author name (leave empty to skip): " author_name
        if [ -n "$author_name" ]; then
            npm config set init-author-name "$author_name"
        fi
        
        read -p "Enter default author email (leave empty to skip): " author_email
        if [ -n "$author_email" ]; then
            npm config set init-author-email "$author_email"
        fi
        
        read -p "Enter default author URL (leave empty to skip): " author_url
        if [ -n "$author_url" ]; then
            npm config set init-author-url "$author_url"
        fi
        
        read -p "Enter default license (leave empty for MIT): " license
        if [ -n "$license" ]; then
            npm config set init-license "$license"
        else
            npm config set init-license "MIT"
        fi
        
        print_success "npm defaults configured."
    fi
else
    print_error "npm is not available. Skipping npm package installation."
fi

print_success "Node.js environment setup completed." 