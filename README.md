# Mac Development Setup

This repository contains scripts to automate the setup of a new Mac for development. It's designed to be modular, allowing you to pick and choose which components to install.

![Demo](demo.gif)

## Features

- **Homebrew**: Package manager for macOS
- **Development Tools**: Install packages from Brewfile
- **Shell Setup**: Configure Zsh, Oh My Zsh, plugins, and themes
- **Git Configuration**: Set up Git with useful aliases and configurations
- **Node.js Setup**: Install nvm, Node.js, and pnpm
- **Python Setup**: Install pyenv, Python versions, and uv
- **Oh My Zsh Backup**: Backup and restore your Oh My Zsh configuration
- **macOS Preferences**: Configure macOS settings for development
- **VSCode Setup**: Backup and restore VSCode settings, extensions, and snippets
- **Comprehensive Mac Backup**: Backup all essential settings from your Mac
- **Security-Focused Design**: Clear separation between public-safe and private backups

## Prerequisites

- macOS (tested on macOS Ventura and later)
- Internet connection
- Admin privileges

## Usage

### Workflow Overview

This repository is designed to be used in two phases:

1. **Backup Phase (On Your Old Mac)**: Run the backup script on your existing Mac to save your settings, configurations, and preferences.
2. **Setup Phase (On Your New Mac)**: Use this repository on your new Mac and run the setup script to restore your environment.

### Repository Setup Options

Since this repository contains scripts that will backup your personal settings, you'll need to decide how to handle these backups:

#### Option 1: Use Public Repository (Recommended for Collaboration)

1. Fork or clone this repository
2. Use the backup script which will automatically separate public-safe and private backups
3. Commit only the public-safe backups to your repository
4. Keep private backups local or in a secure storage solution

#### Option 2: Use Private Repository (For Personal Use)

1. Create a new private repository on GitHub/GitLab/etc.
2. Clone this repository and push it to your private repository:
   ```bash
   # Clone this repository
   git clone https://github.com/sanjeed5/new-mac-setup.git
   cd new-mac-setup
   
   # Change the remote to your private repository
   git remote remove origin
   git remote add origin https://github.com/YOUR_USERNAME/YOUR_PRIVATE_REPO.git
   
   # Push to your private repository
   git push -u origin main
   ```

#### Option 3: Use Local Backups Only (Most Secure)

1. Clone this repository
2. Run the backup script which will create local backups
3. Transfer these backups to your new Mac using external storage or file sharing

### Backup Your Old Mac

1. Set up the repository using one of the options above, then:

2. Make the backup script executable:
   ```bash
   chmod +x backup.sh
   ```

3. Run the backup script:
   ```bash
   ./backup.sh
   ```

4. The script will guide you through backing up different components into the `backups/` directory:
   - `backups/homebrew/`: Homebrew packages and Brewfile
   - `backups/vscode/`: VSCode settings, keybindings, snippets, and extensions
   - `backups/ohmyzsh/`: Oh My Zsh configuration, themes, and plugins
   - `backups/git/`: Git configuration and global settings
   - `backups/macos/`: macOS system preferences and settings

5. If using a repository:
   ```bash
   # For public repositories, only commit the public backups
   git add backups/public
   git commit -m "Backup my public Mac settings"
   git push
   
   # For private repositories, you may choose to commit private backups as well
   git add backups/private
   git commit -m "Backup my private Mac settings"
   git push
   ```
   
   If using local backups only, copy the `backups` directory to external storage.

### Setup Your New Mac

1. Clone the repository:
   ```bash
   git clone https://github.com/YOUR_USERNAME/YOUR_REPO.git
   cd YOUR_REPO
   ```
   
   If using local backups, copy your backup files to the appropriate location:
   ```bash
   # Copy your backup files to the backups directory
   cp -r /path/to/your/backups/* backups/
   ```

2. Make the setup script executable:
   ```bash
   chmod +x setup.sh
   ```

3. Run the setup script:
   ```bash
   ./setup.sh
   ```

4. Follow the prompts to select which components to install and restore from your backup. The script will ask for necessary information (like Git username and email) during the setup process.

## Security Considerations

This repository is designed with security in mind:

### Backup Directory Structure

All backups are stored in the `backups/` directory with the following organization:

1. **Public-Safe Backups**:
   - `backups/homebrew/`: Brewfile and package lists
   - `backups/vscode/extensions.txt`: VSCode extensions list
   - `backups/ohmyzsh/`: Oh My Zsh themes and plugins
   - Other non-sensitive configurations

2. **Private/Sensitive Backups**:
   - `backups/git/`: Git configuration (may contain email)
   - `backups/vscode/settings.json`: VSCode settings (may contain tokens)
   - `backups/macos/`: System preferences (may contain personal settings)
   - Other potentially sensitive data

### Security Warnings

**IMPORTANT**: Never commit sensitive information to a public repository, including:
- Private SSH keys
- API tokens or passwords
- Personal credentials
- Database connection strings with passwords

### Security Recommendations

- **Public Repositories**: Only commit non-sensitive backups
- **Private Repositories**: You may commit both directories, but review files first
- **Highly Sensitive Data**: Consider keeping SSH keys and credentials completely separate from any repository
- **Review Before Committing**: Always check files for sensitive information before committing
- **Use Environment Variables**: Consider using environment variables or a secure vault for sensitive information

## How the Scripts Work

### Backup Script (`backup.sh`)

The backup script:

1. Creates necessary directories in `backups/`
2. Presents options for backing up different components
3. Automatically categorizes backups as public-safe or private/sensitive
4. Provides multiple security warnings for sensitive data
5. Creates timestamped archives of your backups

### Setup Script (`setup.sh`)

The setup script:

1. Installs core development tools (Homebrew, packages from Brewfile)
2. Sets up your shell environment (Zsh, Oh My Zsh, plugins)
3. Configures development tools (Node.js, Python)
4. Sets up Git with your information
5. Configures macOS preferences for development
6. Restores settings from your backups in the `backups/` directory

## Directory Structure

```
.
├── Brewfile                # Homebrew packages and applications
├── README.md              # This file
├── backup.sh              # Main backup script
├── setup.sh               # Main setup script
├── backups/               # All backups are stored here
│   ├── homebrew/         # Homebrew packages and Brewfile
│   ├── vscode/           # VSCode settings and extensions
│   ├── ohmyzsh/          # Oh My Zsh configuration
│   ├── git/              # Git configuration
│   └── macos/            # macOS preferences
└── scripts/              # Individual scripts
    ├── backup_*.sh       # Individual backup scripts
    ├── install_*.sh      # Installation scripts
    ├── restore_*.sh      # Restoration scripts
    └── setup_*.sh        # Setup scripts
```

## License

MIT

## Acknowledgements

This project was inspired by various dotfiles repositories and setup scripts from the developer community.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request. 

## Example Setup

A basic example of configuration files and backups is available in the `example-setup` directory. This can serve as a reference for how the backup and configuration system works.

### Using the Example Setup

If you want to see an example of how the system works before creating your own:

```bash
# Explore the example-setup directory to see the example configurations and backups
ls -la example-setup

# You can copy these example files to the main directory structure if you want to use them
# For example, to use the example configurations:
cp -r example-setup/config/* config/

# Or to use the example public backups:
cp -r example-setup/backups/public/* backups/public/
```

The example provides a starting point to understand how both the configuration and backup structures work. You can use these files as-is or modify them to suit your needs. 