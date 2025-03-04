#!/bin/bash

print_header "Backing up Git Configuration"

# Create backup directory
mkdir -p backups/git

# Backup global Git config
if [ -f "$HOME/.gitconfig" ]; then
    print_info "Backing up global Git config..."
    cp "$HOME/.gitconfig" backups/git/
    print_success "Backed up .gitconfig"
fi

# Backup global gitignore
if [ -f "$HOME/.gitignore_global" ]; then
    print_info "Backing up global gitignore..."
    cp "$HOME/.gitignore_global" backups/git/
    print_success "Backed up .gitignore_global"
fi

# Export Git configuration as individual settings
print_info "Exporting Git settings..."
git config --global --list > backups/git/git_settings.txt
print_success "Exported Git settings to git_settings.txt"

# Create restore script
cat > backups/git/restore_git_settings.sh << 'EOF'
#!/bin/bash

# Restore Git configuration
if [ -f ".gitconfig" ]; then
    cp .gitconfig "$HOME/.gitconfig"
    echo "Restored .gitconfig"
fi

if [ -f ".gitignore_global" ]; then
    cp .gitignore_global "$HOME/.gitignore_global"
    echo "Restored .gitignore_global"
fi

# Restore individual settings
if [ -f "git_settings.txt" ]; then
    while IFS='=' read -r key value; do
        if [ ! -z "$key" ] && [ ! -z "$value" ]; then
            git config --global "$key" "$value"
        fi
    done < git_settings.txt
    echo "Restored Git settings from git_settings.txt"
fi
EOF

chmod +x backups/git/restore_git_settings.sh
print_success "Created restore script"

print_success "Git configuration backup completed!" 