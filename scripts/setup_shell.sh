#!/bin/bash

print_header "Setting Up Shell Environment"

# Check if Zsh is installed
if ! command_exists zsh; then
    print_error "Zsh is not installed. Installing Zsh..."
    brew install zsh
    
    # Set Zsh as default shell
    if [ $? -eq 0 ]; then
        print_info "Setting Zsh as default shell..."
        chsh -s $(which zsh)
        print_success "Zsh set as default shell."
    else
        print_error "Failed to install Zsh."
        exit 1
    fi
else
    print_success "Zsh is already installed."
fi

# Install Oh My Zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_info "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    if [ $? -eq 0 ]; then
        print_success "Oh My Zsh installed successfully."
    else
        print_error "Failed to install Oh My Zsh."
        exit 1
    fi
else
    print_success "Oh My Zsh is already installed."
fi

# Install Zsh plugins
print_info "Setting up Zsh plugins..."

# Install zsh-syntax-highlighting
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting" ]; then
    print_info "Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting installed."
else
    print_success "zsh-syntax-highlighting is already installed."
fi

# Install zsh-autosuggestions
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions" ]; then
    print_info "Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions installed."
else
    print_success "zsh-autosuggestions is already installed."
fi

# Install powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_info "Installing powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "powerlevel10k theme installed."
else
    print_success "powerlevel10k theme is already installed."
fi

# Update .zshrc file
print_info "Updating .zshrc file..."

# Backup existing .zshrc
if [ -f "$HOME/.zshrc" ]; then
    cp "$HOME/.zshrc" "$HOME/.zshrc.backup.$(date +%Y%m%d%H%M%S)"
    print_success "Backed up existing .zshrc file."
fi

# Check if we have a backed-up .zshrc in the repository
if [ -f "config/oh-my-zsh/.zshrc" ]; then
    print_info "Found backed-up .zshrc in repository. Using it..."
    cp "config/oh-my-zsh/.zshrc" "$HOME/.zshrc"
    print_success "Restored .zshrc from repository backup."
    
    # Check if we have a backed-up .p10k.zsh in the repository
    if [ -f "config/oh-my-zsh/.p10k.zsh" ]; then
        print_info "Found backed-up .p10k.zsh in repository. Using it..."
        cp "config/oh-my-zsh/.p10k.zsh" "$HOME/.p10k.zsh"
        print_success "Restored .p10k.zsh from repository backup."
    fi
    
    # Copy any custom themes
    if [ -d "config/oh-my-zsh/custom/themes" ]; then
        print_info "Copying custom themes from repository..."
        cp -R "config/oh-my-zsh/custom/themes"/* "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/" 2>/dev/null || true
        print_success "Restored custom themes from repository backup."
    fi
    
    # Copy any custom plugins
    if [ -d "config/oh-my-zsh/custom/plugins" ]; then
        print_info "Copying custom plugins from repository..."
        cp -R "config/oh-my-zsh/custom/plugins"/* "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/" 2>/dev/null || true
        print_success "Restored custom plugins from repository backup."
    fi
    
    # Copy any custom .zsh files
    if [ -d "config/oh-my-zsh/custom" ]; then
        print_info "Copying custom .zsh files from repository..."
        find "config/oh-my-zsh/custom" -maxdepth 1 -type f -name "*.zsh" -exec cp {} "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/" \; 2>/dev/null || true
        print_success "Restored custom .zsh files from repository backup."
    fi
# Ask if user wants to import existing Oh My Zsh settings
elif confirm "Do you want to import your existing Oh My Zsh settings from a backup?"; then
    print_info "You can import your Oh My Zsh settings in several ways:"
    echo "1. Copy your .zshrc file from your old machine"
    echo "2. Copy your entire .oh-my-zsh directory"
    echo "3. Copy specific custom themes and plugins"
    
    # Option to import .zshrc
    if confirm "Do you want to import your .zshrc file?"; then
        read -p "Enter the path to your .zshrc backup file: " zshrc_path
        if [ -f "$zshrc_path" ]; then
            cp "$zshrc_path" "$HOME/.zshrc"
            print_success "Imported .zshrc file from $zshrc_path"
        else
            print_error "File not found: $zshrc_path"
        fi
    fi
    
    # Option to import custom themes
    if confirm "Do you want to import custom Oh My Zsh themes?"; then
        read -p "Enter the path to your custom themes directory: " themes_path
        if [ -d "$themes_path" ]; then
            mkdir -p "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"
            cp -R "$themes_path"/* "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/"
            print_success "Imported custom themes from $themes_path"
        else
            print_error "Directory not found: $themes_path"
        fi
    fi
    
    # Option to import custom plugins
    if confirm "Do you want to import custom Oh My Zsh plugins?"; then
        read -p "Enter the path to your custom plugins directory: " plugins_path
        if [ -d "$plugins_path" ]; then
            mkdir -p "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"
            cp -R "$plugins_path"/* "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/"
            print_success "Imported custom plugins from $plugins_path"
        else
            print_error "Directory not found: $plugins_path"
        fi
    fi
    
    # Option to import p10k configuration if using powerlevel10k
    if confirm "Do you want to import your Powerlevel10k configuration (p10k.zsh)?"; then
        read -p "Enter the path to your p10k.zsh file: " p10k_path
        if [ -f "$p10k_path" ]; then
            cp "$p10k_path" "$HOME/.p10k.zsh"
            print_success "Imported Powerlevel10k configuration from $p10k_path"
        else
            print_error "File not found: $p10k_path"
        fi
    fi
    
    print_success "Oh My Zsh settings import completed."
# Ask if user wants to use the default .zshrc configuration
elif confirm "Do you want to use the recommended .zshrc configuration?"; then
    cat > "$HOME/.zshrc" << 'EOL'
# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set plugins
plugins=(
  git
  docker
  docker-compose
  npm
  node
  python
  pip
  macos
  brew
  zsh-syntax-highlighting
  zsh-autosuggestions
)

# Source Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export LANG=en_US.UTF-8
export EDITOR='vim'

# Aliases
alias zshconfig="$EDITOR ~/.zshrc"
alias ohmyzsh="$EDITOR ~/.oh-my-zsh"
alias ls="eza --icons"
alias ll="eza -la --icons"
alias la="eza -a --icons"
alias lt="eza --tree --icons"
alias cat="bat"

# NVM setup (if installed)
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# Pyenv setup (if installed)
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init -)"
fi

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOL
    print_success "Created new .zshrc with recommended configuration."
else
    print_info "Skipping .zshrc modification. You can edit it manually later."
fi

# Add option to create a backup of current Oh My Zsh settings
if confirm "Do you want to create a backup of your current Oh My Zsh settings for future use?"; then
    backup_dir="$HOME/ohmyzsh_backup_$(date +%Y%m%d%H%M%S)"
    mkdir -p "$backup_dir"
    
    # Backup .zshrc
    if [ -f "$HOME/.zshrc" ]; then
        cp "$HOME/.zshrc" "$backup_dir/"
        print_success "Backed up .zshrc to $backup_dir"
    fi
    
    # Backup p10k config if exists
    if [ -f "$HOME/.p10k.zsh" ]; then
        cp "$HOME/.p10k.zsh" "$backup_dir/"
        print_success "Backed up .p10k.zsh to $backup_dir"
    fi
    
    # Backup custom themes and plugins
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes" ]; then
        mkdir -p "$backup_dir/themes"
        cp -R "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes"/* "$backup_dir/themes/"
        print_success "Backed up custom themes to $backup_dir/themes"
    fi
    
    if [ -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins" ]; then
        mkdir -p "$backup_dir/plugins"
        cp -R "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins"/* "$backup_dir/plugins/"
        print_success "Backed up custom plugins to $backup_dir/plugins"
    fi
    
    print_success "Oh My Zsh backup created at: $backup_dir"
    print_info "You can use this backup to restore your settings on another machine."
fi

print_success "Shell environment setup completed."
print_info "Note: Some changes may require restarting your terminal or running 'source ~/.zshrc'." 