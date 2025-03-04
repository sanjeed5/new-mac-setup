#!/bin/bash

# Colors for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
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

# Print security warning
print_security_warning() {
    echo -e "${PURPLE}⚠️  SECURITY WARNING: $1${NC}"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Ask for confirmation
confirm() {
    read -p "$1 (y/n): " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# Welcome message
clear
echo -e "${GREEN}=================================${NC}"
echo -e "${GREEN}  Mac Development Backup Script  ${NC}"
echo -e "${GREEN}=================================${NC}"
echo
echo "This script will help you backup your Mac development settings."
echo "You can choose which components to backup."
echo

# Security warning
print_header "SECURITY CONSIDERATIONS"
print_security_warning "This script can collect sensitive information during backup."
print_security_warning "Please read the following security guidelines before proceeding:"
echo
echo "1. By default, this script will ONLY backup public-safe configurations."
echo "2. Sensitive information requires explicit opt-in and should NEVER be committed to public repositories."
echo "3. For sensitive data, we recommend:"
echo "   - Using a PRIVATE repository"
echo "   - Using environment variables or secure storage solutions"
echo "   - Keeping sensitive backups local only (not in any repository)"
echo

# Create necessary directories
mkdir -p scripts
mkdir -p backups
mkdir -p backups/public
mkdir -p backups/private

# Check if running for the first time and create script files
if [ ! -f scripts/backup_ohmyzsh.sh ] || [ ! -f scripts/backup_mac_settings.sh ]; then
    print_info "First run detected. Creating script files..."
    
    # Create backup script files if they don't exist
    touch scripts/backup_ohmyzsh.sh
    touch scripts/backup_mac_settings.sh
    touch scripts/backup_vscode.sh
    touch scripts/backup_ssh.sh
    touch scripts/backup_git.sh
    touch scripts/backup_databases.sh
    touch scripts/backup_browser_profiles.sh
    touch scripts/backup_docker.sh
    touch scripts/backup_homebrew.sh
    touch scripts/backup_node.sh
    touch scripts/backup_python.sh
    
    # Make all scripts executable
    chmod +x scripts/*.sh
fi

print_header "BACKUP OPTIONS"
echo "Please select which components to backup:"
echo

# === PUBLIC-SAFE BACKUPS ===
print_header "PUBLIC-SAFE BACKUPS"
echo "These backups are generally safe to commit to public repositories:"

if confirm "Backup Oh My Zsh configuration? (themes, plugins, etc.)"; then
    source ./scripts/backup_ohmyzsh.sh
fi

if confirm "Backup Homebrew installed packages list?"; then
    source ./scripts/backup_homebrew.sh
fi

if confirm "Backup Node.js global packages?"; then
    source ./scripts/backup_node.sh
fi

if confirm "Backup Python packages list? (not virtual environments)"; then
    source ./scripts/backup_python.sh
fi

if confirm "Backup VSCode extensions list? (not settings)"; then
    # Modify backup_vscode.sh to only backup extensions list, not settings
    source ./scripts/backup_vscode.sh
fi

# === POTENTIALLY SENSITIVE BACKUPS ===
print_header "POTENTIALLY SENSITIVE BACKUPS"
print_security_warning "The following backups may contain sensitive information."
print_security_warning "They should NOT be committed to public repositories."
echo

if confirm "Do you want to see options for potentially sensitive backups?"; then
    # Git configuration
    if confirm "Backup Git global configuration? (may contain email addresses)"; then
        print_security_warning "Git config may contain personal information like email addresses."
        if confirm "Are you using a PRIVATE repository or will keep this backup local only?"; then
            source ./scripts/backup_git.sh
        fi
    fi
    
    # VSCode settings
    if confirm "Backup VSCode settings? (may contain tokens or sensitive paths)"; then
        print_security_warning "VSCode settings may contain API tokens or sensitive paths."
        if confirm "Are you using a PRIVATE repository or will keep this backup local only?"; then
            # Modify backup_vscode.sh to backup settings
            source ./scripts/backup_vscode_settings.sh
        fi
    fi
    
    # Mac settings
    if confirm "Backup Mac settings? (may contain personal preferences)"; then
        print_security_warning "Mac settings may contain personal information."
        if confirm "Are you using a PRIVATE repository or will keep this backup local only?"; then
            source ./scripts/backup_mac_settings.sh
        fi
    fi
    
    # Browser profiles
    if confirm "Backup browser development profiles? (may contain cookies/credentials)"; then
        print_security_warning "Browser profiles may contain cookies, saved passwords, and personal data."
        if confirm "Are you using a PRIVATE repository or will keep this backup local only?"; then
            source ./scripts/backup_browser_profiles.sh
        fi
    fi
fi

# === HIGHLY SENSITIVE BACKUPS ===
print_header "HIGHLY SENSITIVE BACKUPS"
print_security_warning "The following backups contain sensitive information."
print_security_warning "They should NEVER be committed to ANY repository."
print_security_warning "These are best kept local or in a secure password manager."
echo

if confirm "Do you want to see options for highly sensitive backups?"; then
    # SSH keys
    if confirm "Backup SSH keys and config? (HIGHLY SENSITIVE)"; then
        print_security_warning "SSH keys are extremely sensitive! Private keys should NEVER be committed to ANY repository."
        print_security_warning "It is recommended to keep these backups completely separate from your repository."
        if confirm "Do you understand the risks and still want to proceed with SSH backup?"; then
            source ./scripts/backup_ssh.sh
        fi
    fi
    
    # Database configurations
    if confirm "Backup database configurations? (HIGHLY SENSITIVE)"; then
        print_security_warning "Database configurations contain passwords and connection strings."
        print_security_warning "It is recommended to keep these backups completely separate from your repository."
        if confirm "Do you understand the risks and still want to proceed with database config backup?"; then
            source ./scripts/backup_databases.sh
        fi
    fi
    
    # Docker configurations
    if confirm "Backup Docker configurations? (HIGHLY SENSITIVE)"; then
        print_security_warning "Docker configurations may contain registry credentials."
        print_security_warning "It is recommended to keep these backups completely separate from your repository."
        if confirm "Do you understand the risks and still want to proceed with Docker config backup?"; then
            source ./scripts/backup_docker.sh
        fi
    fi
fi

# Create timestamps for the backups
timestamp=$(date +"%Y%m%d_%H%M%S")

# Create public backup archive
echo "Creating public backup archive..."
tar -czf "backups/public_backup_${timestamp}.tar.gz" -C backups/public .
print_success "Created public backup archive: backups/public_backup_${timestamp}.tar.gz"

# Create private backup archive if there are private backups
if [ "$(ls -A backups/private)" ]; then
    echo "Creating private backup archive..."
    tar -czf "backups/private_backup_${timestamp}.tar.gz" -C backups/private .
    print_success "Created private backup archive: backups/private_backup_${timestamp}.tar.gz"
    
    print_header "Security Reminder for Private Backups"
    print_security_warning "Your private backup archive contains sensitive information."
    print_security_warning "Please keep it secure and do not commit it to public repositories."
    echo "Consider storing it in a secure location or using a password manager."
fi

print_header "Backup Complete!"
echo "Your Mac settings have been backed up according to your preferences."
echo
echo "Public-safe backups: backups/public_backup_${timestamp}.tar.gz"
if [ "$(ls -A backups/private)" ]; then
    echo "Private backups: backups/private_backup_${timestamp}.tar.gz"
fi
echo
echo "Backup completed successfully! 💾" 