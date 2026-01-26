#!/usr/bin/env bash

# =============================================================================
# Mac Development Environment Setup
# =============================================================================
# This script automates the setup of a complete development environment on macOS
# All configurations are symlinked from this repository, so changes are tracked.
# =============================================================================

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Symbols
SUCCESS="✓"
ERROR="✗"
INFO="→"
ARROW="➜"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# =============================================================================
# Helper Functions
# =============================================================================

print_header() {
    echo ""
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

print_step() {
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}$1${NC}"
}

print_success() {
    echo -e "${GREEN}${SUCCESS}${NC} $1"
}

print_error() {
    echo -e "${RED}${ERROR}${NC} $1"
}

print_info() {
    echo -e "${YELLOW}${INFO}${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC}  $1"
}

ask_confirmation() {
    while true; do
        read -p "$(echo -e ${CYAN}$1 [y/N]: ${NC})" yn
        case $yn in
            [Yy]* ) return 0;;
            [Nn]*|"" ) return 1;;
            * ) echo "Please answer yes or no.";;
        esac
    done
}

safe_symlink() {
    local source="$1"
    local target="$2"
    local backup_suffix="backup.$(date +%Y%m%d_%H%M%S)"

    # Remove existing symlink if it points to the right place
    if [[ -L "$target" ]]; then
        current_link=$(readlink "$target")
        if [[ "$current_link" == "$source" ]]; then
            print_success "Already linked: $target → $source"
            return 0
        else
            print_info "Removing old symlink: $target → $current_link"
            rm "$target"
        fi
    fi

    # Backup existing file/directory
    if [[ -e "$target" ]]; then
        backup_path="${target}.${backup_suffix}"
        print_info "Backing up existing $target to $backup_path"
        mv "$target" "$backup_path"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create symlink
    ln -s "$source" "$target"
    print_success "Linked: $target → $source"
}

# =============================================================================
# Installation Functions
# =============================================================================

install_xcode_tools() {
    print_step "Checking Xcode Command Line Tools..."

    if xcode-select -p &> /dev/null; then
        print_success "Xcode Command Line Tools already installed"
    else
        print_info "Installing Xcode Command Line Tools..."
        xcode-select --install
        print_warning "Please complete the Xcode installation and run this script again"
        exit 0
    fi
}

install_homebrew() {
    print_step "Checking Homebrew..."

    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
        print_info "Updating Homebrew..."
        brew update
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == 'arm64' ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        print_success "Homebrew installed successfully"
    fi
}

install_brewfile() {
    print_step "Installing packages from Brewfile..."

    if [[ ! -f "$SCRIPT_DIR/.Brewfile" ]]; then
        print_error "Brewfile not found at $SCRIPT_DIR/.Brewfile"
        exit 1
    fi

    print_info "This will install all packages, apps, and VSCode extensions..."
    brew bundle --file="$SCRIPT_DIR/.Brewfile" --verbose

    print_success "Brewfile packages installed"
}

setup_oh_my_zsh() {
    print_step "Checking Oh My Zsh..."

    if [[ -d "$HOME/.oh-my-zsh" ]]; then
        print_success "Oh My Zsh already installed"
    else
        print_info "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed"
    fi
}

install_zsh_lazyload() {
    print_step "Installing zsh-lazyload plugin..."

    ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
    LAZYLOAD_DIR="$ZSH_CUSTOM/plugins/zsh-lazyload"

    if [[ -d "$LAZYLOAD_DIR" ]]; then
        print_success "zsh-lazyload already installed"
    else
        print_info "Cloning zsh-lazyload..."
        git clone https://github.com/qoomon/zsh-lazyload.git "$LAZYLOAD_DIR"
        print_success "zsh-lazyload installed"
    fi
}

link_dotfiles() {
    print_step "Linking dotfiles from repository..."

    if [[ ! -d "$DOTFILES_DIR" ]]; then
        print_error "Dotfiles directory not found at $DOTFILES_DIR"
        exit 1
    fi

    # Link zsh configuration
    if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
        safe_symlink "$DOTFILES_DIR/zsh/.zshrc" "$HOME/.zshrc"
    else
        print_warning ".zshrc not found in dotfiles"
    fi

    # Link WezTerm configuration
    if [[ -f "$DOTFILES_DIR/wezterm/.wezterm.lua" ]]; then
        safe_symlink "$DOTFILES_DIR/wezterm/.wezterm.lua" "$HOME/.wezterm.lua"
    else
        print_warning ".wezterm.lua not found in dotfiles"
    fi

    # Link Neovim configuration
    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        safe_symlink "$DOTFILES_DIR/nvim" "$HOME/.config/nvim"
        print_info "Plugins will be installed on first Neovim launch"
    else
        print_warning "Neovim config not found in dotfiles"
    fi

    # Link Git configuration (optional, as we also configure it below)
    if [[ -f "$DOTFILES_DIR/git/.gitconfig" ]]; then
        if ask_confirmation "Link Git config from repository (will ask for name/email)?"; then
            safe_symlink "$DOTFILES_DIR/git/.gitconfig" "$HOME/.gitconfig"
        fi
    fi

    print_success "Dotfiles linked successfully"
    print_info "All changes to configs in this repository will be reflected immediately"
}

setup_nvm() {
    print_step "Configuring NVM..."

    # Create NVM directory (in ~/.nvm to match existing setup)
    mkdir -p "$HOME/.nvm"

    # Source NVM for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"

    # Install Node LTS if NVM is available
    if command -v nvm &> /dev/null; then
        print_info "Installing Node.js LTS..."
        nvm install --lts
        nvm alias default lts/*
        print_success "Node.js LTS installed and set as default"
    else
        print_warning "NVM not available yet, will be configured in .zshrc"
    fi

    print_success "NVM configured"
}

setup_sdkman() {
    print_step "Setting up SDKMAN..."

    if [[ -d "$HOME/.sdkman" ]]; then
        print_success "SDKMAN already installed"
    else
        print_info "Installing SDKMAN..."
        curl -s "https://get.sdkman.io" | bash
        print_success "SDKMAN installed"
    fi

    # Source SDKMAN for current session
    export SDKMAN_DIR="$HOME/.sdkman"
    [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

    print_info "You can install Java versions with: sdk install java"
    print_info "Example: sdk install java 21.0.1-tem"
}

setup_pyenv() {
    print_step "Configuring pyenv..."

    if command -v pyenv &> /dev/null; then
        # Initialize pyenv for current session
        export PYENV_ROOT="$HOME/.pyenv"
        [[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
        eval "$(pyenv init -)"

        # Check if any Python version is installed
        if pyenv versions --bare | grep -q .; then
            print_success "pyenv already configured with Python versions"
        else
            print_info "Installing Python (latest stable)..."
            pyenv install --skip-existing $(pyenv install --list | grep -E '^\s*[0-9]+\.[0-9]+\.[0-9]+$' | tail -1 | tr -d ' ')
            pyenv global $(pyenv versions --bare | tail -1)
            print_success "Python installed and set as default"
        fi
    else
        print_warning "pyenv not found, will be available after Brewfile install"
    fi

    print_info "Install Python versions with: pyenv install 3.11.7"
    print_info "Set global version with: pyenv global 3.11.7"
}

setup_atuin() {
    print_step "Configuring Atuin..."

    if command -v atuin &> /dev/null; then
        if [[ ! -d "$HOME/.local/share/atuin" ]]; then
            print_info "Importing existing shell history..."
            atuin import auto || true
            print_success "Atuin configured"
        else
            print_success "Atuin already configured"
        fi
    else
        print_warning "Atuin not found, will be available after Brewfile install"
    fi
}

setup_fzf() {
    print_step "Setting up FZF key bindings..."

    if command -v fzf &> /dev/null; then
        if [[ ! -f "$HOME/.fzf.zsh" ]]; then
            print_info "Installing FZF key bindings..."
            $(brew --prefix)/opt/fzf/install --key-bindings --completion --no-update-rc
            print_success "FZF configured"
        else
            print_success "FZF already configured"
        fi
    fi
}

setup_git_config() {
    print_step "Configuring Git..."

    # Only configure if not using the linked .gitconfig
    if [[ ! -L "$HOME/.gitconfig" ]]; then
        if [[ -z $(git config --global user.name) ]]; then
            read -p "Enter your Git name: " git_name
            git config --global user.name "$git_name"
        fi

        if [[ -z $(git config --global user.email) ]]; then
            read -p "Enter your Git email: " git_email
            git config --global user.email "$git_email"
        fi

        # Set default branch name
        git config --global init.defaultBranch main

        # Better git log
        git config --global alias.lg "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

        print_success "Git configured"
        print_info "Name: $(git config --global user.name)"
        print_info "Email: $(git config --global user.email)"
    else
        # Update the linked gitconfig with user info
        print_info "Git config is symlinked from repository"
        if [[ -z $(git config --global user.name) ]]; then
            read -p "Enter your Git name: " git_name
            git config --global user.name "$git_name"
        fi

        if [[ -z $(git config --global user.email) ]]; then
            read -p "Enter your Git email: " git_email
            git config --global user.email "$git_email"
        fi
        print_success "Git user info configured"
    fi
}

create_secrets_file() {
    print_step "Setting up secrets file..."

    if [[ ! -f "$HOME/.secrets" ]]; then
        print_info "Creating ~/.secrets template..."
        cat > "$HOME/.secrets" << 'EOF'
# =============================================================================
# Secrets and Environment Variables
# =============================================================================
# This file is sourced by .zshrc
# NEVER commit this file to version control!
#
# Add your tokens, API keys, and sensitive environment variables here
# Example:
#
# export GITHUB_PAT="your_github_token_here"
# export GITHUB_PERSONAL_ACCESS_TOKEN="your_token_here"
# export GOOGLE_CLOUD_PROJECT="your-gcp-project"
# export DATABASE_URL="postgres://..."
#
# For project-specific variables, consider using direnv instead:
# Create a .envrc file in your project directory

EOF
        print_success "Created ~/.secrets template"
        print_warning "Add your credentials to ~/.secrets"
    else
        print_success "~/.secrets already exists"
    fi
}

setup_macos_defaults() {
    print_step "Configuring macOS defaults..."

    if ask_confirmation "Apply recommended macOS settings?"; then
        # Show hidden files in Finder
        defaults write com.apple.finder AppleShowAllFiles -bool true

        # Show path bar in Finder
        defaults write com.apple.finder ShowPathbar -bool true

        # Show status bar in Finder
        defaults write com.apple.finder ShowStatusBar -bool true

        # Avoid creating .DS_Store files on network volumes
        defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

        # Show all file extensions
        defaults write NSGlobalDomain AppleShowAllExtensions -bool true

        # Disable the "Are you sure you want to open this application?" dialog
        defaults write com.apple.LaunchServices LSQuarantine -bool false

        # Enable key repeat (for Vim)
        defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false
        defaults write NSGlobalDomain KeyRepeat -int 1
        defaults write NSGlobalDomain InitialKeyRepeat -int 10

        # Restart Finder to apply changes
        killall Finder

        print_success "macOS defaults configured"
        print_info "Some changes may require a logout/restart"
    else
        print_warning "Skipping macOS defaults"
    fi
}

print_next_steps() {
    print_header "Setup Complete!"

    echo -e "${GREEN}${SUCCESS}${NC} Your Mac development environment is ready!"
    echo ""
    echo -e "${BOLD}${CYAN}Repository Info:${NC}"
    echo -e "  ${INFO} All configs are symlinked from: ${YELLOW}$SCRIPT_DIR/dotfiles/${NC}"
    echo -e "  ${INFO} Changes to configs in this repo are reflected immediately"
    echo -e "  ${INFO} Commit and push changes to keep your setup in sync"
    echo ""
    echo -e "${BOLD}Next Steps:${NC}"
    echo ""
    echo -e "  ${CYAN}1.${NC} Restart your terminal or run: ${YELLOW}source ~/.zshrc${NC}"
    echo -e "  ${CYAN}2.${NC} Launch Neovim to complete plugin installation: ${YELLOW}nvim${NC}"
    echo -e "  ${CYAN}3.${NC} Sign in to Mac App Store to install Magnet: ${YELLOW}mas install 441258766${NC}"
    echo -e "  ${CYAN}4.${NC} Open Docker Desktop and accept the license"
    echo -e "  ${CYAN}5.${NC} Configure Raycast (System Preferences → Extensions)"
    echo -e "  ${CYAN}6.${NC} Add your credentials to: ${YELLOW}~/.secrets${NC}"
    echo ""
    echo -e "${BOLD}Language Version Managers:${NC}"
    echo ""
    echo -e "  ${YELLOW}sdk list java${NC}        - List available Java versions"
    echo -e "  ${YELLOW}sdk install java 21.0.1-tem${NC} - Install Java 21"
    echo -e "  ${YELLOW}pyenv install 3.12.1${NC} - Install Python 3.12.1"
    echo -e "  ${YELLOW}pyenv global 3.12.1${NC}  - Set default Python version"
    echo ""
    echo -e "${BOLD}MongoDB:${NC}"
    echo ""
    echo -e "  ${YELLOW}brew services start mongodb-community${NC} - Start MongoDB"
    echo -e "  ${YELLOW}mongosh${NC}                              - MongoDB shell"
    echo -e "  Open ${YELLOW}MongoDB Compass${NC} app for GUI"
    echo ""
    echo -e "${BOLD}Useful Commands:${NC}"
    echo ""
    echo -e "  ${YELLOW}lazygit${NC}      - Git TUI"
    echo -e "  ${YELLOW}lazydocker${NC}   - Docker TUI"
    echo -e "  ${YELLOW}k9s${NC}          - Kubernetes TUI"
    echo -e "  ${YELLOW}htop${NC}         - Process monitor"
    echo -e "  ${YELLOW}nvim${NC}         - Neovim editor"
    echo ""
    echo -e "${BOLD}Installed Aliases:${NC}"
    echo ""
    echo -e "  ${YELLOW}ls${NC}   → eza"
    echo -e "  ${YELLOW}ll${NC}   → eza -la"
    echo -e "  ${YELLOW}lt${NC}   → eza --tree"
    echo -e "  ${YELLOW}cat${NC}  → bat"
    echo -e "  ${YELLOW}vim${NC}  → nvim"
    echo -e "  ${YELLOW}k${NC}    → kubectl"
    echo ""
    echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# =============================================================================
# Main Installation Flow
# =============================================================================

main() {
    clear

    print_header "🚀 Mac Development Environment Setup"

    echo -e "${BOLD}This script will install and configure:${NC}"
    echo ""
    echo -e "  ${GREEN}•${NC} Homebrew package manager"
    echo -e "  ${GREEN}•${NC} Development tools (Git, Docker, Kubernetes, MongoDB, etc.)"
    echo -e "  ${GREEN}•${NC} Programming languages (Go, Elixir, Java via SDKMAN, Node.js, Python via pyenv)"
    echo -e "  ${GREEN}•${NC} Modern CLI utilities (eza, bat, fzf, ripgrep)"
    echo -e "  ${GREEN}•${NC} Neovim with your LazyVim configuration"
    echo -e "  ${GREEN}•${NC} Zsh with Oh My Zsh and plugins"
    echo -e "  ${GREEN}•${NC} Shell enhancements (atuin, direnv, nvm)"
    echo -e "  ${GREEN}•${NC} Applications (Docker Desktop, Raycast, WezTerm)"
    echo ""
    echo -e "${BOLD}${YELLOW}All configurations will be symlinked from this repository!${NC}"
    echo -e "${YELLOW}Location: $SCRIPT_DIR${NC}"
    echo ""

    if ! ask_confirmation "Continue with installation?"; then
        print_warning "Installation cancelled"
        exit 0
    fi

    echo ""

    # Run installation steps
    install_xcode_tools
    install_homebrew
    install_brewfile
    setup_oh_my_zsh
    install_zsh_lazyload
    link_dotfiles          # ← NEW: Replaces individual setup functions
    setup_nvm
    setup_sdkman
    setup_pyenv
    setup_atuin
    setup_fzf
    setup_git_config
    create_secrets_file
    setup_macos_defaults

    # Print completion message
    print_next_steps
}

# Run main function
main "$@"
