# Security Guidelines

This document outlines security best practices for using this repository and its scripts.

## Critical Security Warnings

### Never Commit Sensitive Information

**NEVER** commit the following types of sensitive information to any repository (public or private):

- Private SSH keys (files starting with `id_` without `.pub` extension)
- API tokens or access keys
- Passwords or credentials
- Database connection strings with passwords
- Personal information you don't want to be public
- Environment files (`.env`)
- Configuration files with secrets

### Safe Usage of Backup Scripts

The backup scripts in this repository are designed to help you save your development environment configuration. However, they can potentially collect sensitive information. Follow these guidelines:

1. **Review Before Committing**: Always review the contents of the `config/mac_backup` directory before committing changes.
2. **Use Example Files**: Replace sensitive information with example placeholders before committing.
3. **Secure Local Backups**: For truly sensitive information, use the secure backup options that store data outside the repository.

## Security Features in This Repository

1. **Enhanced .gitignore**: The repository includes a comprehensive `.gitignore` file that attempts to exclude common sensitive files.
2. **Example Templates**: Configuration files are provided as examples with placeholders instead of real credentials.
3. **Security Warnings**: Backup scripts include prominent warnings before collecting potentially sensitive information.
4. **Secure Backup Options**: Options to backup sensitive data to locations outside the Git repository.

## Best Practices

### SSH Keys

- Generate new SSH keys for each machine rather than transferring private keys
- Use passphrase-protected SSH keys
- Consider using hardware security keys where possible

### Git Configuration

- Use Git configuration templates with placeholders for personal information
- Consider using Git aliases to simplify common operations without exposing sensitive information

### Credentials Management

- Use a password manager for sensitive credentials
- Consider using environment variables for sensitive information in scripts
- Look into secure credential storage solutions like:
  - macOS Keychain
  - Credential managers integrated with your tools

## Reporting Security Issues

If you discover a security vulnerability in this repository, please report it by [creating an issue](https://github.com/yourusername/new-mac-setup/issues) or contacting the repository owner directly.

## Additional Resources

- [GitHub Security Best Practices](https://docs.github.com/en/code-security)
- [Git Documentation on Credentials Storage](https://git-scm.com/book/en/v2/Git-Tools-Credential-Storage)
- [SSH Key Best Practices](https://www.ssh.com/academy/ssh/keygen)

## Handling Sensitive Files in This Repository

### Sensitive Directories

The following directories may contain sensitive information and should be carefully reviewed before committing:

```
config/mac_backup/ssh/       # SSH keys and configuration
config/mac_backup/docker/    # Docker credentials and configuration
config/mac_backup/macos/     # macOS system preferences and configuration
```

### Untracking Sensitive Files

If you've already tracked sensitive files, you can remove them from Git tracking without deleting them from your filesystem:

```bash
# Remove sensitive directories from Git tracking
git rm --cached -r config/mac_backup/ssh/ config/mac_backup/docker/ config/mac_backup/macos/

# Remove specific sensitive files
git rm --cached config/mac_backup/git/.gitconfig
git rm --cached config/mac_backup/ssh/id_ed25519.pub
git rm --cached config/mac_backup/ssh/config
```

### Checking for Sensitive Information

Before committing, search for sensitive terms in your codebase:

```bash
# Search for sensitive terms
grep -r "password\|secret\|token\|key\|credential" .
```

Review all files that contain these terms and ensure they don't contain actual sensitive information. 