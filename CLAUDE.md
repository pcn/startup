# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a personal dotfiles and system configuration repository for setting up development environments across different platforms (Linux, macOS, Pop!_OS). The primary focus is on Emacs configuration with language support and shell customization.

## Architecture

### Emacs Configuration (`emacs/`)
- **Package Manager**: Uses Elpaca (not package.el) for package management
- **Configuration Structure**: Modular settings files in `emacs/settings/` loaded in specific order
- **Bootstrap**: `early-init.el` disables package.el, `init.el` sets up Elpaca and loads settings
- **Settings Loading Order** (from init.el:70-87):
  1. `early-misc.el` - Basic settings
  2. `development-settings.el` - LSP/DAP foundation
  3. `ivy-settings.el` - After development for lsp-ivy integration
  4. Language-specific settings (rust, python, clojure, typescript, golang)
  5. Feature and UI settings

### Platform-Specific Configurations
- `linux/` - Bash configuration and utilities
- `mac/` - macOS-specific shell profile
- `pop-os/` - Pop!_OS desktop environment settings (dconf)
- `tmux.conf` - Terminal multiplexer configuration

## Installation Commands

### Emacs Setup
```bash
# Install Emacs 29+ (Ubuntu)
sudo add-apt-repository ppa:ubuntuhandbook1/emacs
sudo apt install emacs

# Link configuration files
mkdir ~/.emacs.d
cd ~/.emacs.d
ln -s ~/dvcs/pcn/startup/emacs/{early-init.el,init.el,settings} .
```

### Docker Installation
```bash
# Full Docker CE setup (from docker/README.md)
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Rust Development
```bash
# Install Rust toolchain
rustup component add rust-analyzer
sudo apt install cmake
cargo install ripgrep starship
```

### Pop!_OS Desktop Settings
```bash
# Restore desktop configuration
dconf load / < pop-os/keymap.dconf
```

## Key Configuration Files

- `emacs/init.el` - Main Emacs configuration entry point
- `emacs/settings/development-settings.el` - LSP, DAP, and development tools
- `linux/dot-bashrc` - Bash shell configuration
- `tmux.conf` - Terminal multiplexer with backtick prefix
- `pop-os/keymap.dconf` - Desktop environment keybindings

## Dependencies

- Emacs 29+ (requires libsqlite3-dev for proper operation)
- Git (for Elpaca package management)
- Rust toolchain with rust-analyzer
- Docker CE
- ripgrep and starship (Rust tools)
- cmake (for Rust compilation)