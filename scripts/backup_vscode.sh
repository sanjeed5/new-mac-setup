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

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

print_header "Backing up VSCode Settings"

# Create backup directory
mkdir -p backups/vscode

# Check if VSCode is installed
if ! command_exists "code"; then
    print_error "VSCode is not installed. Skipping VSCode backup."
    exit 0
fi

# Backup VSCode settings
vscode_settings_dir="$HOME/Library/Application Support/Code/User"
if [ -d "$vscode_settings_dir" ]; then
    print_info "Backing up VSCode settings..."
    
    # Copy settings.json
    if [ -f "$vscode_settings_dir/settings.json" ]; then
        cp "$vscode_settings_dir/settings.json" backups/vscode/
        print_success "Backed up settings.json"
    else
        print_info "No settings.json found"
    fi
    
    # Copy keybindings.json
    if [ -f "$vscode_settings_dir/keybindings.json" ]; then
        cp "$vscode_settings_dir/keybindings.json" backups/vscode/
        print_success "Backed up keybindings.json"
    else
        print_info "No keybindings.json found"
    fi
    
    # Copy snippets
    if [ -d "$vscode_settings_dir/snippets" ]; then
        mkdir -p backups/vscode/snippets
        cp -R "$vscode_settings_dir/snippets/"* backups/vscode/snippets/
        print_success "Backed up code snippets"
    else
        print_info "No snippets found"
    fi
    
    # Export list of extensions
    print_info "Exporting list of installed extensions..."
    code --list-extensions > backups/vscode/extensions.txt
    print_success "Exported list of installed extensions to extensions.txt"
    
    # Create a script to restore extensions
    cat > backups/vscode/restore_extensions.sh << 'EOF'
#!/bin/bash
while read extension; do
    code --install-extension "$extension"
done < extensions.txt
EOF
    chmod +x backups/vscode/restore_extensions.sh
    print_success "Created restore_extensions.sh script"
    
else
    print_error "VSCode settings directory not found at $vscode_settings_dir"
fi

print_success "VSCode backup completed!" 