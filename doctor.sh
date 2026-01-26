#!/usr/bin/env bash

# =============================================================================
# Mac Development Environment Health Check
# =============================================================================
# Checks if all components are properly installed and configured
# =============================================================================

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'
BOLD='\033[1m'

SUCCESS="✓"
ERROR="✗"
WARNING="⚠"

ERRORS=0
WARNINGS=0

check_command() {
    local cmd=$1
    local name=$2
    local install_cmd=$3

    if command -v "$cmd" &> /dev/null; then
        local version=$($cmd --version 2>&1 | head -n 1)
        echo -e "${GREEN}${SUCCESS}${NC} ${name}: ${version}"
    else
        echo -e "${RED}${ERROR}${NC} ${name}: Not found"
        if [[ -n "$install_cmd" ]]; then
            echo -e "  ${YELLOW}Install with: ${install_cmd}${NC}"
        fi
        ((ERRORS++))
    fi
}

check_directory() {
    local dir=$1
    local name=$2

    if [[ -d "$dir" ]]; then
        echo -e "${GREEN}${SUCCESS}${NC} ${name}: Found at ${dir}"
    else
        echo -e "${RED}${ERROR}${NC} ${name}: Not found at ${dir}"
        ((ERRORS++))
    fi
}

check_file() {
    local file=$1
    local name=$2

    if [[ -f "$file" ]]; then
        echo -e "${GREEN}${SUCCESS}${NC} ${name}: Found"
    else
        echo -e "${YELLOW}${WARNING}${NC} ${name}: Not found at ${file}"
        ((WARNINGS++))
    fi
}

check_symlink() {
    local target=$1
    local expected_source=$2
    local name=$3

    if [[ -L "$target" ]]; then
        actual_source=$(readlink "$target")
        if [[ "$actual_source" == "$expected_source" ]]; then
            echo -e "${GREEN}${SUCCESS}${NC} ${name}: Properly symlinked"
            echo -e "  ${CYAN}→${NC} $target → $expected_source"
        else
            echo -e "${RED}${ERROR}${NC} ${name}: Incorrect symlink"
            echo -e "  ${YELLOW}Expected:${NC} $expected_source"
            echo -e "  ${RED}Actual:${NC} $actual_source"
            ((ERRORS++))
        fi
    elif [[ -e "$target" ]]; then
        echo -e "${YELLOW}${WARNING}${NC} ${name}: Exists but not a symlink"
        echo -e "  ${INFO} Run ./setup.sh to convert to symlink"
        ((WARNINGS++))
    else
        echo -e "${RED}${ERROR}${NC} ${name}: Not found at ${target}"
        echo -e "  ${INFO} Run ./setup.sh to create symlink"
        ((ERRORS++))
    fi
}

check_git_config() {
    local key=$1
    local name=$2

    local value=$(git config --global "$key")
    if [[ -n "$value" ]]; then
        echo -e "${GREEN}${SUCCESS}${NC} Git ${name}: ${value}"
    else
        echo -e "${YELLOW}${WARNING}${NC} Git ${name}: Not configured"
        ((WARNINGS++))
    fi
}

echo ""
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}  🏥 Development Environment Health Check${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Check core tools
echo -e "${BOLD}Core Tools:${NC}"
check_command "brew" "Homebrew" "/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
check_command "git" "Git" "brew install git"
check_command "nvim" "Neovim" "brew install neovim"
check_command "zsh" "Zsh" "brew install zsh"
echo ""

# Check modern CLI tools
echo -e "${BOLD}Modern CLI Tools:${NC}"
check_command "eza" "eza" "brew install eza"
check_command "bat" "bat" "brew install bat"
check_command "fzf" "fzf" "brew install fzf"
check_command "rg" "ripgrep" "brew install ripgrep"
check_command "jq" "jq" "brew install jq"
check_command "htop" "htop" "brew install htop"
echo ""

# Check TUI tools
echo -e "${BOLD}TUI Tools:${NC}"
check_command "lazygit" "Lazygit" "brew install lazygit"
check_command "lazydocker" "Lazydocker" "brew install lazydocker"
check_command "k9s" "k9s" "brew install derailed/k9s/k9s"
echo ""

# Check development tools
echo -e "${BOLD}Development Tools:${NC}"
check_command "docker" "Docker" "brew install docker"
check_command "kubectl" "Kubernetes CLI" "brew install kubernetes-cli"
check_command "helm" "Helm" "brew install helm"
check_command "gh" "GitHub CLI" "brew install gh"
echo ""

# Check languages
echo -e "${BOLD}Programming Languages:${NC}"
check_command "go" "Go" "brew install go"
check_command "elixir" "Elixir" "brew install elixir"
check_command "gleam" "Gleam" "brew install gleam"
check_command "node" "Node.js" "nvm install --lts"
check_command "java" "Java" "brew install openjdk"
echo ""

# Check shell enhancements
echo -e "${BOLD}Shell Enhancements:${NC}"
check_command "atuin" "Atuin" "brew install atuin"
check_command "direnv" "Direnv" "brew install direnv"
check_command "tmux" "Tmux" "brew install tmux"
check_command "stow" "Stow" "brew install stow"
echo ""

# Check NVM
echo -e "${BOLD}Node Version Manager:${NC}"
if [[ -d "$HOME/.nvm" ]]; then
    echo -e "${GREEN}${SUCCESS}${NC} NVM directory: Found at ~/.nvm"
    export NVM_DIR="$HOME/.nvm"
    if [[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]]; then
        source "$(brew --prefix)/opt/nvm/nvm.sh"
        if command -v nvm &> /dev/null; then
            echo -e "${GREEN}${SUCCESS}${NC} NVM: $(nvm --version)"
            echo -e "${GREEN}${SUCCESS}${NC} Node versions installed:"
            nvm list | sed 's/^/  /'
        else
            echo -e "${YELLOW}${WARNING}${NC} NVM script found but nvm command not available"
            ((WARNINGS++))
        fi
    else
        echo -e "${YELLOW}${WARNING}${NC} NVM script not found at $(brew --prefix)/opt/nvm/nvm.sh"
        ((WARNINGS++))
    fi
else
    echo -e "${YELLOW}${WARNING}${NC} NVM directory: Not found at ~/.nvm"
    echo -e "${YELLOW}→${NC} Run: mkdir -p ~/.nvm && brew reinstall nvm"
    ((WARNINGS++))
fi
echo ""

# Determine dotfiles directory path
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

# Check repository location
echo -e "${BOLD}Repository:${NC}"
if [[ -d "$DOTFILES_DIR" ]]; then
    echo -e "${GREEN}${SUCCESS}${NC} Dotfiles directory: Found at $DOTFILES_DIR"

    # Check dotfiles structure
    if [[ -f "$DOTFILES_DIR/zsh/.zshrc" ]]; then
        echo -e "${GREEN}${SUCCESS}${NC} Zsh dotfile: Present in repository"
    else
        echo -e "${RED}${ERROR}${NC} Zsh dotfile: Missing at $DOTFILES_DIR/zsh/.zshrc"
        ((ERRORS++))
    fi

    if [[ -f "$DOTFILES_DIR/wezterm/.wezterm.lua" ]]; then
        echo -e "${GREEN}${SUCCESS}${NC} WezTerm dotfile: Present in repository"
    else
        echo -e "${RED}${ERROR}${NC} WezTerm dotfile: Missing at $DOTFILES_DIR/wezterm/.wezterm.lua"
        ((ERRORS++))
    fi

    if [[ -d "$DOTFILES_DIR/nvim" ]]; then
        echo -e "${GREEN}${SUCCESS}${NC} Neovim dotfile: Present in repository"
    else
        echo -e "${RED}${ERROR}${NC} Neovim dotfile: Missing at $DOTFILES_DIR/nvim"
        ((ERRORS++))
    fi
else
    echo -e "${RED}${ERROR}${NC} Dotfiles directory: Not found at $DOTFILES_DIR"
    echo -e "  ${INFO} Make sure this script is run from the Brew repository"
    ((ERRORS++))
fi
echo ""

# Check symlinked configurations
echo -e "${BOLD}Symlinked Configurations:${NC}"
if [[ -d "$DOTFILES_DIR" ]]; then
    check_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc" "Zsh config"
    check_symlink "$HOME/.wezterm.lua" "$DOTFILES_DIR/wezterm/.wezterm.lua" "WezTerm config"
    check_symlink "$HOME/.config/nvim" "$DOTFILES_DIR/nvim" "Neovim config"

    # Check optional git config symlink
    if [[ -L "$HOME/.gitconfig" ]]; then
        check_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig" "Git config"
    else
        echo -e "${CYAN}${INFO}${NC} Git config: Not symlinked (using standard setup)"
    fi
else
    echo -e "${RED}${ERROR}${NC} Cannot check symlinks - dotfiles directory not found"
fi
echo ""

# Check other configurations
echo -e "${BOLD}Other Configurations:${NC}"
check_directory "$HOME/.oh-my-zsh" "Oh My Zsh"
check_file "$HOME/.fzf.zsh" "FZF config"
echo ""

# Check Git configuration
echo -e "${BOLD}Git Configuration:${NC}"
check_git_config "user.name" "name"
check_git_config "user.email" "email"
check_git_config "init.defaultBranch" "default branch"
echo ""

# Check shell integrations in .zshrc
echo -e "${BOLD}Shell Integrations:${NC}"
if [[ -f "$HOME/.zshrc" ]]; then
    if grep -q "zsh-autosuggestions" "$HOME/.zshrc"; then
        echo -e "${GREEN}${SUCCESS}${NC} zsh-autosuggestions: Configured"
    else
        echo -e "${YELLOW}${WARNING}${NC} zsh-autosuggestions: Not configured in .zshrc"
        ((WARNINGS++))
    fi

    if grep -q "zsh-syntax-highlighting" "$HOME/.zshrc"; then
        echo -e "${GREEN}${SUCCESS}${NC} zsh-syntax-highlighting: Configured"
    else
        echo -e "${YELLOW}${WARNING}${NC} zsh-syntax-highlighting: Not configured in .zshrc"
        ((WARNINGS++))
    fi

    if grep -q "atuin init" "$HOME/.zshrc"; then
        echo -e "${GREEN}${SUCCESS}${NC} atuin: Configured"
    else
        echo -e "${YELLOW}${WARNING}${NC} atuin: Not configured in .zshrc"
        ((WARNINGS++))
    fi

    if grep -q "direnv hook" "$HOME/.zshrc"; then
        echo -e "${GREEN}${SUCCESS}${NC} direnv: Configured"
    else
        echo -e "${YELLOW}${WARNING}${NC} direnv: Not configured in .zshrc"
        ((WARNINGS++))
    fi

    if grep -q "NVM_DIR" "$HOME/.zshrc"; then
        echo -e "${GREEN}${SUCCESS}${NC} nvm: Configured"
    else
        echo -e "${YELLOW}${WARNING}${NC} nvm: Not configured in .zshrc"
        ((WARNINGS++))
    fi
fi
echo ""

# Check applications
echo -e "${BOLD}Applications:${NC}"
if [[ -d "/Applications/Docker.app" ]]; then
    echo -e "${GREEN}${SUCCESS}${NC} Docker Desktop: Installed"
else
    echo -e "${YELLOW}${WARNING}${NC} Docker Desktop: Not found"
    ((WARNINGS++))
fi

if [[ -d "/Applications/WezTerm.app" ]]; then
    echo -e "${GREEN}${SUCCESS}${NC} WezTerm: Installed"
else
    echo -e "${YELLOW}${WARNING}${NC} WezTerm: Not found"
    ((WARNINGS++))
fi

if [[ -d "/Applications/Raycast.app" ]]; then
    echo -e "${GREEN}${SUCCESS}${NC} Raycast: Installed"
else
    echo -e "${YELLOW}${WARNING}${NC} Raycast: Not found"
    ((WARNINGS++))
fi
echo ""

# Summary
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
if [[ $ERRORS -eq 0 && $WARNINGS -eq 0 ]]; then
    echo -e "${BOLD}${GREEN}${SUCCESS} All checks passed! Your environment is healthy.${NC}"
elif [[ $ERRORS -eq 0 ]]; then
    echo -e "${BOLD}${YELLOW}${WARNING} ${WARNINGS} warning(s) found. Everything essential is working.${NC}"
else
    echo -e "${BOLD}${RED}${ERROR} ${ERRORS} error(s) and ${WARNINGS} warning(s) found.${NC}"
    echo -e "${YELLOW}Run ./setup.sh to fix missing components.${NC}"
fi
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Exit with error code if there are errors
if [[ $ERRORS -gt 0 ]]; then
    exit 1
fi
