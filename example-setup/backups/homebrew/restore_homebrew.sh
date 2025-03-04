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
