#!/bin/bash

print_header "Setting Up macOS Preferences"

# Ask for administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

# Set computer name
if confirm "Do you want to set a custom computer name?"; then
    read -p "Enter computer name: " computer_name
    if [ -n "$computer_name" ]; then
        sudo scutil --set ComputerName "$computer_name"
        sudo scutil --set HostName "$computer_name"
        sudo scutil --set LocalHostName "$computer_name"
        sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$computer_name"
        print_success "Computer name set to: $computer_name"
    else
        print_error "Computer name not provided. Skipping."
    fi
fi

# Finder preferences
if confirm "Do you want to configure Finder preferences?"; then
    print_info "Configuring Finder preferences..."
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    
    # Show file extensions
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    # Keep folders on top when sorting by name
    defaults write com.apple.finder _FXSortFoldersFirst -bool true
    
    # Search current folder by default
    defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
    
    # Avoid creating .DS_Store files on network or USB volumes
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    
    # Use list view in all Finder windows by default
    defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"
    
    print_success "Finder preferences configured."
fi

# Dock preferences
if confirm "Do you want to configure Dock preferences?"; then
    print_info "Configuring Dock preferences..."
    
    # Set the icon size
    defaults write com.apple.dock tilesize -int 48
    
    # Minimize windows into their application's icon
    defaults write com.apple.dock minimize-to-application -bool true
    
    # Show indicator lights for open applications
    defaults write com.apple.dock show-process-indicators -bool true
    
    # Don't automatically rearrange Spaces based on most recent use
    defaults write com.apple.dock mru-spaces -bool false
    
    # Don't show recent applications in Dock
    defaults write com.apple.dock show-recents -bool false
    
    print_success "Dock preferences configured."
fi

# Safari preferences
if confirm "Do you want to configure Safari preferences?"; then
    print_info "Configuring Safari preferences..."
    
    # Show the full URL in the address bar
    defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
    
    # Enable the Develop menu and the Web Inspector
    defaults write com.apple.Safari IncludeDevelopMenu -bool true
    defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
    
    # Add a context menu item for showing the Web Inspector in web views
    defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
    
    print_success "Safari preferences configured."
fi

# Terminal preferences
if confirm "Do you want to configure Terminal preferences?"; then
    print_info "Configuring Terminal preferences..."
    
    # Only use UTF-8 in Terminal.app
    defaults write com.apple.terminal StringEncodings -array 4
    
    print_success "Terminal preferences configured."
fi

# Keyboard preferences
if confirm "Do you want to configure keyboard preferences?"; then
    print_info "Configuring keyboard preferences..."
    
    # Set a fast keyboard repeat rate
    defaults write NSGlobalDomain KeyRepeat -int 2
    defaults write NSGlobalDomain InitialKeyRepeat -int 15
    
    # Disable automatic capitalization
    defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false
    
    # Disable smart dashes
    defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false
    
    # Disable automatic period substitution
    defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false
    
    # Disable smart quotes
    defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false
    
    # Disable auto-correct
    defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
    
    print_success "Keyboard preferences configured."
fi

# Screenshots
if confirm "Do you want to configure screenshot preferences?"; then
    print_info "Configuring screenshot preferences..."
    
    # Save screenshots to the desktop
    mkdir -p "${HOME}/Desktop/Screenshots"
    defaults write com.apple.screencapture location -string "${HOME}/Desktop/Screenshots"
    
    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    defaults write com.apple.screencapture type -string "png"
    
    # Disable shadow in screenshots
    defaults write com.apple.screencapture disable-shadow -bool true
    
    print_success "Screenshot preferences configured."
fi

# Restart affected applications
print_info "Restarting affected applications..."
for app in "Finder" "Dock" "Safari" "Terminal"; do
    killall "${app}" &> /dev/null
done

print_success "macOS preferences configured. Some changes may require a logout/restart to take effect." 