#!/bin/bash

print_header "Setting Up Git Configuration"

# Check if Git is installed
if ! command_exists git; then
    print_error "Git is not installed. Installing Git..."
    brew install git
    
    if [ $? -ne 0 ]; then
        print_error "Failed to install Git."
        exit 1
    fi
else
    print_success "Git is already installed."
fi

# Configure Git user information
print_info "Configuring Git user information..."

# Set default Git user information
default_name="Your Name"
default_email="your.email@example.com"

# Get current Git user name and email if set
current_name=$(git config --global user.name)
current_email=$(git config --global user.email)

# Ask for Git user name if not set
if [ -z "$current_name" ]; then
    read -p "Enter your Git user name (default: $default_name): " git_name
    if [ -z "$git_name" ]; then
        git_name=$default_name
    fi
    
    git config --global user.name "$git_name"
    print_success "Git user name set to: $git_name"
else
    print_info "Current Git user name: $current_name"
    if confirm "Do you want to change your Git user name to $default_name?"; then
        git config --global user.name "$default_name"
        print_success "Git user name updated to: $default_name"
    fi
fi

# Ask for Git user email if not set
if [ -z "$current_email" ]; then
    read -p "Enter your Git user email (default: $default_email): " git_email
    if [ -z "$git_email" ]; then
        git_email=$default_email
    fi
    
    git config --global user.email "$git_email"
    print_success "Git user email set to: $git_email"
else
    print_info "Current Git user email: $current_email"
    if confirm "Do you want to change your Git user email to $default_email?"; then
        git config --global user.email "$default_email"
        print_success "Git user email updated to: $default_email"
    fi
fi

# Configure Git default branch
if confirm "Do you want to set 'main' as the default branch name for new repositories?"; then
    git config --global init.defaultBranch main
    print_success "Default branch name set to 'main'."
fi

# Configure Git editor
if confirm "Do you want to configure your preferred Git editor?"; then
    # Determine available editors
    editors=()
    
    if command_exists vim; then
        editors+=("vim")
    fi
    
    if command_exists nano; then
        editors+=("nano")
    fi
    
    if command_exists code; then
        editors+=("code --wait")
    fi
    
    if command_exists subl; then
        editors+=("subl -n -w")
    fi
    
    if [ ${#editors[@]} -eq 0 ]; then
        print_error "No suitable editors found. Skipping editor configuration."
    else
        echo "Available editors:"
        for i in "${!editors[@]}"; do
            echo "$((i+1)). ${editors[$i]}"
        done
        
        read -p "Select an editor (1-${#editors[@]}) or enter a custom editor: " editor_choice
        
        if [[ "$editor_choice" =~ ^[0-9]+$ ]] && [ "$editor_choice" -ge 1 ] && [ "$editor_choice" -le ${#editors[@]} ]; then
            selected_editor=${editors[$((editor_choice-1))]}
            git config --global core.editor "$selected_editor"
            print_success "Git editor set to: $selected_editor"
        elif [ -n "$editor_choice" ]; then
            git config --global core.editor "$editor_choice"
            print_success "Git editor set to: $editor_choice"
        else
            print_error "Invalid selection. Skipping editor configuration."
        fi
    fi
fi

# Configure useful Git aliases
if confirm "Do you want to set up useful Git aliases?"; then
    print_info "Setting up Git aliases..."
    
    git config --global alias.co checkout
    git config --global alias.br branch
    git config --global alias.ci commit
    git config --global alias.st status
    git config --global alias.unstage 'reset HEAD --'
    git config --global alias.last 'log -1 HEAD'
    git config --global alias.visual '!gitk'
    git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
    
    print_success "Git aliases configured."
fi

# Configure Git credential helper
if confirm "Do you want to set up Git credential helper (for storing passwords)?"; then
    print_info "Setting up Git credential helper..."
    
    # Use macOS Keychain for credential storage
    git config --global credential.helper osxkeychain
    
    print_success "Git credential helper configured to use macOS Keychain."
fi

# Configure global .gitignore
if confirm "Do you want to set up a global .gitignore file?"; then
    print_info "Setting up global .gitignore..."
    
    global_gitignore="$HOME/.gitignore_global"
    
    # Create global .gitignore file with common patterns
    cat > "$global_gitignore" << 'EOL'
# macOS
.DS_Store
.AppleDouble
.LSOverride
Icon
._*
.DocumentRevisions-V100
.fseventsd
.Spotlight-V100
.TemporaryItems
.Trashes
.VolumeIcon.icns
.com.apple.timemachine.donotpresent

# Node.js
node_modules/
npm-debug.log
yarn-debug.log
yarn-error.log
.pnpm-debug.log
.env
.env.local
.env.development.local
.env.test.local
.env.production.local

# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
build/
develop-eggs/
dist/
downloads/
eggs/
.eggs/
lib/
lib64/
parts/
sdist/
var/
*.egg-info/
.installed.cfg
*.egg
.pytest_cache/
.coverage
htmlcov/
.tox/
.nox/
.hypothesis/
.venv
venv/
ENV/

# IDE specific files
.idea/
.vscode/
*.swp
*.swo
*~
.project
.classpath
.settings/
*.sublime-workspace
*.sublime-project
EOL
    
    # Configure Git to use the global .gitignore file
    git config --global core.excludesfile "$global_gitignore"
    
    print_success "Global .gitignore file created and configured."
fi

print_success "Git configuration completed." 