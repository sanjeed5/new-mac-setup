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

print_header "Backing up Homebrew Packages"

# Create backup directory
mkdir -p backups/homebrew

# Check if Homebrew is installed
if ! command_exists "brew"; then
    print_error "Homebrew is not installed. Skipping Homebrew backup."
    exit 0
fi

# Backup Homebrew packages
print_info "Exporting list of installed Homebrew packages..."

# Export all installed formulae
brew leaves > backups/homebrew/brew_leaves.txt
print_success "Exported list of top-level formulae to brew_leaves.txt"

# Export all installed casks
brew list --cask > backups/homebrew/brew_casks.txt
print_success "Exported list of installed casks to brew_casks.txt"

# Export all taps
brew tap > backups/homebrew/brew_taps.txt
print_success "Exported list of taps to brew_taps.txt"

# Create a complete Brewfile
print_info "Creating Brewfile with all installed packages..."
brew bundle dump --file=backups/homebrew/Brewfile
print_success "Created Brewfile with all installed packages"

# Create a restore script
cat > backups/homebrew/restore_homebrew.sh << 'EOF'
#!/bin/bash

# Check if Homebrew is installed
if ! command -v brew >/dev/null 2>&1; then
    echo "Homebrew is not installed. Please install Homebrew first."
    echo "Run: /bin/bash -c \"$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
    exit 1
fi

# Add taps
echo "Adding taps..."
while read tap; do
    brew tap "$tap"
done < brew_taps.txt

# Install from Brewfile (preferred method)
echo "Installing packages from Brewfile..."
brew bundle install --file=Brewfile

echo "Homebrew packages restored successfully!"
EOF

chmod +x backups/homebrew/restore_homebrew.sh
print_success "Created restore_homebrew.sh script"

print_success "Homebrew backup completed!" 