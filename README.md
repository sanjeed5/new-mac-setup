# Mac Development Setup

This repository contains scripts to automate the setup of a new Mac for development. It's designed to be modular, allowing you to pick and choose which components to install.

## Features

- **Homebrew**: Package manager for macOS
- **Development Tools**: Install packages from Brewfile
- **Shell Setup**: Configure Zsh, Oh My Zsh, plugins, and themes
- **Git Configuration**: Set up Git with useful aliases and configurations
- **Node.js Setup**: Install nvm, Node.js, and pnpm
- **Python Setup**: Install pyenv, Python versions, and uv
- **macOS Preferences**: Configure macOS settings for development
- **Oh My Zsh Backup**: Backup and restore your Oh My Zsh configuration
- **Comprehensive Mac Backup**: Backup all essential settings from your Mac
- **Security-Focused Design**: Clear separation between public-safe and private backups

## Prerequisites

- macOS (tested on macOS Ventura and later)
- Internet connection
- Admin privileges

## Usage

### Workflow Overview

This repository is designed to be used in two phases:

1. **Backup Phase (On Your Old Mac)**: First, run the backup script on your existing Mac to save your settings, configurations, and preferences.
2. **Setup Phase (On Your New Mac)**: Then, use this repository on your new Mac and run the setup script to restore your environment.

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

4. The script will guide you through backing up different components and will automatically separate:
   - **Public-safe backups**: Configurations that don't contain sensitive information
   - **Private backups**: Configurations that may contain sensitive information

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

4. Follow the prompts to select which components to install and restore from your backup.

## Security Considerations

This repository is designed with security in mind:

### Public vs. Private Backups

The backup script automatically separates backups into two categories:

1. **Public-Safe Backups** (in `backups/public/`):
   - Oh My Zsh configuration (themes, plugins)
   - Homebrew packages list
   - Node.js global packages list
   - Python packages list
   - VSCode extensions list
   - Other non-sensitive configurations

2. **Private Backups** (in `backups/private/`):
   - SSH keys and configuration
   - Git global configuration
   - VSCode settings
   - Database configurations
   - Docker credentials
   - VSCode settings (may contain tokens)
   - Browser profiles
   - Other potentially sensitive data

### Security Recommendations

- **Public Repositories**: Only commit the `backups/public/` directory
- **Private Repositories**: You may commit both directories, but review files first
- **Highly Sensitive Data**: Consider keeping SSH keys and credentials completely separate from any repository
- **Review Before Committing**: Always check files for sensitive information before committing

## Customization

### Brewfile

The `Brewfile` contains all the packages, applications, and VS Code extensions to be installed via Homebrew. You can edit this file to add or remove packages according to your needs.

### Scripts

The repository is organized around two main scripts:

- `backup.sh`: The main backup script that handles backing up all your Mac settings
- `setup.sh`: The main setup script that handles installing and configuring your new Mac

These main scripts call individual component scripts in the `scripts` directory, but you don't need to run these component scripts directly. The modular design allows you to select which components to backup or install when running the main scripts.

## What's Included

### Shell Setup

- Zsh as the default shell
- Oh My Zsh for shell customization
- Powerlevel10k theme
- Useful plugins (syntax highlighting, autosuggestions, etc.)
- **Import/Backup functionality**: Transfer your Oh My Zsh settings from your old machine

### Comprehensive Mac Settings Backup

The `backup.sh` script creates a complete backup of your essential Mac settings, separated into public and private categories:

1. **Public-Safe Backups**:
   - Homebrew packages list
   - npm global packages
   - Python packages list
   - VSCode extensions list
   - Shell themes and plugins
   - Application preferences (non-sensitive)

2. **Private Backups**:
   - SSH keys and configuration
   - Git global configuration
   - VSCode settings
   - Database configurations
   - Docker credentials
   - Browser profiles
   - macOS preferences
   - And more sensitive data

### Git Configuration

- User information setup
- Useful aliases
- Global .gitignore file
- Credential helper configuration

### Node.js Setup

- nvm for Node.js version management
- pnpm as the preferred package manager
- Common global packages

### Python Setup

- pyenv for Python version management
- uv for package management
- Common Python packages

## License

MIT

## Security

This repository contains scripts that may collect sensitive information during backup operations. Please read the security guidelines in this README before using these scripts.

Key security points:
- Never commit private SSH keys or credentials
- Use example configuration files as templates
- Review all files before committing to a repository
- Consider secure alternatives for truly sensitive information

## Acknowledgements

This project was inspired by various dotfiles repositories and setup scripts from the developer community.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Directory Structure

```
.
├── Brewfile                # Homebrew packages and applications
├── README.md               # This file
├── backup.sh               # Main backup script
├── setup.sh                # Main setup script
├── backups/                # Backup storage
│   ├── public/             # Public-safe backups
│   └── private/            # Private, sensitive backups
├── config/                 # Configuration files
│   ├── git/                # Git configuration
│   ├── shell/              # Shell configuration files
│   └── vscode/             # VS Code settings and extensions
└── scripts/                # Setup and utility scripts
    ├── backup_*.sh         # Individual backup scripts
    ├── install_*.sh        # Installation scripts
    ├── restore_*.sh        # Restoration scripts
    └── setup_*.sh          # Setup scripts
``` 