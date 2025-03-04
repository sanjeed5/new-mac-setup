#!/bin/bash

print_header "Setting Up Python Environment"

# Check if pyenv is installed
if ! command_exists pyenv; then
    print_info "pyenv is not installed. Installing pyenv..."
    
    # Check if Homebrew is installed
    if ! command_exists brew; then
        print_error "Homebrew is not installed. Please install Homebrew first."
        exit 1
    fi
    
    # Install pyenv using Homebrew
    brew install pyenv
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install pyenv."
        exit 1
    else
        print_success "pyenv installed successfully."
    fi
    
    # Install pyenv dependencies
    print_info "Installing pyenv dependencies..."
    brew install openssl readline sqlite3 xz zlib tcl-tk
    print_success "pyenv dependencies installed."
    
    # Configure shell for pyenv
    print_info "Configuring shell for pyenv..."
    
    # Determine which shell is being used
    if [[ $SHELL == *"zsh"* ]]; then
        if ! grep -q 'eval "$(pyenv init --path)"' ~/.zprofile; then
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zprofile
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zprofile
            echo 'eval "$(pyenv init --path)"' >> ~/.zprofile
        fi
        
        if ! grep -q 'eval "$(pyenv init -)"' ~/.zshrc; then
            echo 'eval "$(pyenv init -)"' >> ~/.zshrc
        fi
    elif [[ $SHELL == *"bash"* ]]; then
        if ! grep -q 'eval "$(pyenv init --path)"' ~/.bash_profile; then
            echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
            echo 'export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
            echo 'eval "$(pyenv init --path)"' >> ~/.bash_profile
        fi
        
        if ! grep -q 'eval "$(pyenv init -)"' ~/.bashrc; then
            echo 'eval "$(pyenv init -)"' >> ~/.bashrc
        fi
    fi
    
    print_success "Shell configured for pyenv."
    
    # Initialize pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
else
    print_success "pyenv is already installed."
    
    # Update pyenv
    print_info "Updating pyenv..."
    brew upgrade pyenv
    print_success "pyenv updated."
    
    # Initialize pyenv
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# Install Python versions
if command_exists pyenv; then
    # List available Python versions
    print_info "Available Python versions:"
    pyenv install --list | grep -v "a\|b" | grep "^  [0-9]" | tail -10
    
    # Install latest Python version
    if confirm "Do you want to install the latest stable Python version?"; then
        latest_python=$(pyenv install --list | grep -v "a\|b" | grep "^  [0-9]" | tail -1 | tr -d ' ')
        print_info "Installing Python $latest_python..."
        pyenv install $latest_python
        
        if [ $? -eq 0 ]; then
            print_success "Python $latest_python installed successfully."
            
            # Set as global Python version
            if confirm "Do you want to set Python $latest_python as the global version?"; then
                pyenv global $latest_python
                print_success "Python $latest_python set as global version."
            fi
        else
            print_error "Failed to install Python $latest_python."
        fi
    fi
    
    # Ask if user wants to install additional Python versions
    if confirm "Do you want to install additional Python versions?"; then
        read -p "Enter Python versions to install (e.g., 3.9.7 3.8.12): " python_versions
        
        for version in $python_versions; do
            print_info "Installing Python $version..."
            pyenv install $version
            
            if [ $? -eq 0 ]; then
                print_success "Python $version installed successfully."
            else
                print_error "Failed to install Python $version."
            fi
        done
    fi
    
    # Install pyenv-virtualenv
    if ! command_exists pyenv-virtualenv; then
        print_info "Installing pyenv-virtualenv..."
        brew install pyenv-virtualenv
        
        # Configure shell for pyenv-virtualenv
        if [[ $SHELL == *"zsh"* ]]; then
            if ! grep -q 'eval "$(pyenv virtualenv-init -)"' ~/.zshrc; then
                echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc
            fi
        elif [[ $SHELL == *"bash"* ]]; then
            if ! grep -q 'eval "$(pyenv virtualenv-init -)"' ~/.bashrc; then
                echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.bashrc
            fi
        fi
        
        # Initialize pyenv-virtualenv
        eval "$(pyenv virtualenv-init -)"
        
        print_success "pyenv-virtualenv installed and configured."
    else
        print_success "pyenv-virtualenv is already installed."
    fi
else
    print_error "pyenv is not available. Skipping Python installation."
fi

# Install uv (Python package installer)
if command_exists pip; then
    if ! command_exists uv; then
        print_info "Installing uv (Python package installer)..."
        pip install uv
        
        if [ $? -eq 0 ]; then
            print_success "uv installed successfully."
            
            # Add uv to shell configuration
            if [[ $SHELL == *"zsh"* ]]; then
                if ! grep -q 'alias pip="uv pip"' ~/.zshrc; then
                    echo '# Use uv instead of pip' >> ~/.zshrc
                    echo 'alias pip="uv pip"' >> ~/.zshrc
                    echo 'alias venv="uv venv"' >> ~/.zshrc
                fi
            elif [[ $SHELL == *"bash"* ]]; then
                if ! grep -q 'alias pip="uv pip"' ~/.bashrc; then
                    echo '# Use uv instead of pip' >> ~/.bashrc
                    echo 'alias pip="uv pip"' >> ~/.bashrc
                    echo 'alias venv="uv venv"' >> ~/.bashrc
                fi
            fi
        else
            print_error "Failed to install uv. Using pip instead."
        fi
    else
        print_success "uv is already installed."
    fi
    
    # Determine which package installer to use
    PACKAGE_INSTALLER="pip"
    INSTALL_ARGS="--user"
    
    if command_exists uv; then
        PACKAGE_INSTALLER="uv pip"
        INSTALL_ARGS=""
    fi
    
    # Install common Python packages
    if confirm "Do you want to install common Python packages?"; then
        print_info "Installing common Python packages..."
        
        # List of common Python packages
        packages=(
            "pip"
            "setuptools"
            "wheel"
            "virtualenv"
            "pipenv"
            "poetry"
            "black"
            "flake8"
            "pylint"
            "mypy"
            "pytest"
            "jupyter"
            "notebook"
            "numpy"
            "pandas"
            "matplotlib"
            "requests"
            "beautifulsoup4"
            "flask"
            "django"
            "fastapi"
        )
        
        echo "Available packages to install:"
        for i in "${!packages[@]}"; do
            echo "$((i+1)). ${packages[$i]}"
        done
        
        read -p "Enter package numbers to install (e.g., 1 2 3) or 'all' for all packages: " package_selection
        
        if [ "$package_selection" = "all" ]; then
            for package in "${packages[@]}"; do
                print_info "Installing $package..."
                $PACKAGE_INSTALLER install $INSTALL_ARGS $package
                print_success "$package installed."
            done
        else
            for num in $package_selection; do
                if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#packages[@]} ]; then
                    package=${packages[$((num-1))]}
                    print_info "Installing $package..."
                    $PACKAGE_INSTALLER install $INSTALL_ARGS $package
                    print_success "$package installed."
                else
                    print_error "Invalid selection: $num. Skipping."
                fi
            done
        fi
    fi
    
    # Ask if user wants to install custom Python packages
    if confirm "Do you want to install custom Python packages?"; then
        read -p "Enter Python packages to install (space-separated): " custom_packages
        
        for package in $custom_packages; do
            print_info "Installing $package..."
            $PACKAGE_INSTALLER install $INSTALL_ARGS $package
            
            if [ $? -eq 0 ]; then
                print_success "$package installed."
            else
                print_error "Failed to install $package. Please check the output above for details."
            fi
        done
    fi
else
    print_error "pip is not available. Skipping Python package installation."
fi

print_success "Python environment setup completed." 