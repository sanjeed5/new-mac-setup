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

# Ask for confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

print_header "Restoring Mac Settings from Backup"

# Define backup directory
backup_dir="backups/macos"

# Check if backup directory exists
if [ ! -d "$backup_dir" ]; then
    print_error "Backup directory not found at $backup_dir"
    exit 1
fi

# Restore macOS preferences
print_info "Restoring macOS preferences..."

# Function to restore a plist file
restore_plist() {
    local domain=$1
    local file=$2
    
    if [ -f "$file" ]; then
        defaults import "$domain" "$file" 2>/dev/null
        if [ $? -eq 0 ]; then
            print_success "Restored $domain preferences"
        else
            print_error "Failed to restore $domain preferences"
        fi
    else
        print_info "No backup found for $domain, skipping"
    fi
}

# Restore Dock settings
restore_plist "com.apple.dock" "$backup_dir/dock.plist"

# Restore Finder settings
restore_plist "com.apple.finder" "$backup_dir/finder.plist"

# Restore Terminal settings
restore_plist "com.apple.Terminal" "$backup_dir/terminal.plist"

# Restore iTerm2 settings
if [ -f "$backup_dir/com.googlecode.iterm2.plist" ]; then
    cp "$backup_dir/com.googlecode.iterm2.plist" "$HOME/Library/Preferences/" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Restored iTerm2 preferences"
    else
        print_error "Failed to restore iTerm2 preferences"
    fi
fi

# Restore mouse settings
restore_plist "com.apple.driver.AppleBluetoothMultitouch.mouse" "$backup_dir/mouse.plist"

# Restore trackpad settings
restore_plist "com.apple.driver.AppleBluetoothMultitouch.trackpad" "$backup_dir/trackpad.plist"
restore_plist "com.apple.AppleMultitouchTrackpad" "$backup_dir/apple_trackpad.plist"

# Restore keyboard settings
restore_plist "com.apple.keyboard" "$backup_dir/keyboard.plist"
restore_plist "com.apple.HIToolbox" "$backup_dir/input_sources.plist"

# Restore display settings
restore_plist "com.apple.displays" "$backup_dir/displays.plist"

# Restore sound settings
restore_plist "com.apple.sound" "$backup_dir/sound.plist"

# Restore accessibility settings
restore_plist "com.apple.universalaccess" "$backup_dir/accessibility.plist"

# Restore system preferences
restore_plist "com.apple.systempreferences" "$backup_dir/systempreferences.plist"

# Restore global domain settings
if [ -f "$backup_dir/global_domain/global_domain.plist" ]; then
    defaults import -g "$backup_dir/global_domain/global_domain.plist" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Restored global system preferences"
    else
        print_error "Failed to restore global system preferences"
    fi
fi

# Restore hosts file (requires sudo)
if [ -f "$backup_dir/hosts" ] && confirm "Do you want to restore the hosts file? (requires sudo)"; then
    sudo cp "$backup_dir/hosts" "/etc/hosts" 2>/dev/null
    if [ $? -eq 0 ]; then
        print_success "Restored hosts file"
    else
        print_error "Failed to restore hosts file"
    fi
fi

# Restore Raycast settings (if installed)
print_info "Restoring Raycast configuration..."
raycast_dir="$HOME/Library/Application Support/com.raycast.macos"

# Check if Raycast is installed
if [ -d "$raycast_dir" ]; then
    # Check if we have automatic backup files
    if [ -d "$backup_dir/raycast" ] && [ -f "$backup_dir/raycast/preferences.json" ]; then
        # Restore Raycast preferences
        cp -R "$backup_dir/raycast/preferences.json" "$raycast_dir/" 2>/dev/null || true
        # Restore extensions data
        cp -R "$backup_dir/raycast/extensions-data" "$raycast_dir/" 2>/dev/null || true
        # Restore installed extensions list
        cp -R "$backup_dir/raycast/extensions.json" "$raycast_dir/" 2>/dev/null || true
        print_success "Raycast configuration restored"
    else
        print_info "No automatic Raycast backup found, skipping automatic restore"
    fi
    
    # Check for manually exported Raycast settings
    if [ -d "$backup_dir/raycast" ]; then
        rayconfig_files=$(find "$backup_dir/raycast" -name "*.rayconfig" 2>/dev/null)
        if [ -n "$rayconfig_files" ]; then
            print_info "Manually exported Raycast settings found:"
            for file in $rayconfig_files; do
                echo "  - $(basename "$file")"
            done
            print_info "To restore these settings, open Raycast and go to Preferences > Advanced > Import"
            print_info "The exported files are located at: $backup_dir/raycast/"
        fi
    fi
else
    print_info "Raycast not installed, skipping configuration restore"
    if [ -d "$backup_dir/raycast" ]; then
        rayconfig_files=$(find "$backup_dir/raycast" -name "*.rayconfig" 2>/dev/null)
        if [ -n "$rayconfig_files" ]; then
            print_info "Manually exported Raycast settings found. After installing Raycast, you can import them from:"
            print_info "$backup_dir/raycast/"
        fi
    fi
fi

print_info "Some settings may require logging out or restarting your Mac to take effect."
print_success "Mac settings restoration completed!" 