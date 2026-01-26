#!/usr/bin/env bash

# =============================================================================
# Mac Development Environment Update Script
# =============================================================================
# Updates all components of your development environment
# Configs are symlinked, so changes in this repo are automatically reflected
# =============================================================================

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'
BOLD='\033[1m'

# Symbols
SUCCESS="✓"
ARROW="➜"
WARNING="⚠"
INFO="→"

# Script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DOTFILES_DIR="$SCRIPT_DIR/dotfiles"

echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${CYAN}  🔄 Updating Development Environment${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Profile selection from command-line argument
profile=""
if [[ "$1" == "--work" ]]; then
    profile="work"
    echo -e "${INFO} Using 'work' profile for Brewfile sync."
elif [[ "$1" == "--private" ]]; then
    profile="private"
    echo -e "${INFO} Using 'private' profile for Brewfile sync."
elif [[ -n "$1" ]]; then
    echo -e "${RED}✗${NC} Invalid argument '$1'. Use '--work' or '--private'."
    exit 1
else
    echo -e "${YELLOW}${WARNING}${NC} No profile specified. Brewfile sync will only use the base Brewfile."
fi
echo ""

# Update this repository (if it's a git repo)
if [[ -d "$SCRIPT_DIR/.git" ]]; then
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Updating dotfiles repository...${NC}"

    # Check for uncommitted changes
    if [[ -n $(git -C "$SCRIPT_DIR" status --porcelain) ]]; then
        echo -e "${YELLOW}${WARNING}${NC} You have uncommitted changes in this repository:"
        git -C "$SCRIPT_DIR" status --short
        echo ""
        read -p "$(echo -e ${CYAN}Stash changes and pull updates? [y/N]: ${NC})" yn
        case $yn in
            [Yy]* )
                git -C "$SCRIPT_DIR" stash
                git -C "$SCRIPT_DIR" pull --rebase
                echo -e "${GREEN}${SUCCESS}${NC} Repository updated"
                echo -e "${YELLOW}${INFO}${NC} Your changes are stashed. Run 'git stash pop' to restore them."
                ;;
            * )
                echo -e "${YELLOW}${WARNING}${NC} Skipping repository update"
                ;;
        esac
    else
        git -C "$SCRIPT_DIR" pull --rebase
        echo -e "${GREEN}${SUCCESS}${NC} Repository updated"
    fi
    echo ""
fi

# Verify symlinks are still valid
echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Verifying dotfile symlinks...${NC}"
check_symlink() {
    local target="$1"
    local expected_source="$2"

    if [[ -L "$target" ]]; then
        actual_source=$(readlink "$target")
        if [[ "$actual_source" == "$expected_source" ]]; then
            echo -e "${GREEN}${SUCCESS}${NC} $target → $expected_source"
        else
            echo -e "${YELLOW}${WARNING}${NC} $target points to wrong location: $actual_source"
            echo -e "  ${INFO} Expected: $expected_source"
            echo -e "  ${INFO} Run ./setup.sh to fix"
        fi
    else
        echo -e "${RED}✗${NC} $target is not a symlink!"
        echo -e "  ${INFO} Run ./setup.sh to set up symlinks"
    fi
}

check_symlink "$HOME/.zshrc" "$DOTFILES_DIR/zsh/.zshrc"
check_symlink "$HOME/.wezterm.lua" "$DOTFILES_DIR/wezterm/.wezterm.lua"
check_symlink "$HOME/.config/nvim" "$DOTFILES_DIR/nvim"

if [[ -L "$HOME/.gitconfig" ]]; then
    check_symlink "$HOME/.gitconfig" "$DOTFILES_DIR/git/.gitconfig"
fi

echo ""

# Update Homebrew
echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Updating Homebrew...${NC}"
brew update
echo -e "${GREEN}${SUCCESS}${NC} Homebrew updated"
echo ""

# Upgrade packages
echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Upgrading packages...${NC}"
brew upgrade
echo -e "${GREEN}${SUCCESS}${NC} Packages upgraded"
echo ""

# Sync with Brewfiles
base_brewfile="$SCRIPT_DIR/Brewfile"
if [[ -f "$base_brewfile" ]]; then
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Syncing with Brewfiles...${NC}"

    temp_brewfile=$(mktemp)
    # Ensure temp file is cleaned up on exit
    trap 'rm -f "$temp_brewfile"' EXIT

    cat "$base_brewfile" > "$temp_brewfile"

    if [[ -n "$profile" ]]; then
        profile_brewfile="$SCRIPT_DIR/Brewfile.$profile"
        if [[ -f "$profile_brewfile" ]]; then
            echo "" >> "$temp_brewfile" # add newline
            cat "$profile_brewfile" >> "$temp_brewfile"
            echo -e "${INFO} Including packages from Brewfile.$profile"
        else
            echo -e "${YELLOW}${WARNING}${NC} Profile Brewfile for '$profile' not found at $profile_brewfile. Skipping."
        fi
    fi

    echo -e "${YELLOW}${INFO}${NC} This will uninstall packages not listed in your selected Brewfiles."

    # Run cleanup and capture output
    CLEANUP_OUTPUT=$(brew bundle cleanup --file="$temp_brewfile" --force 2>&1)

    # Check if anything was removed
    if echo "$CLEANUP_OUTPUT" | grep -q "Uninstalling"; then
        echo -e "${GREEN}${SUCCESS}${NC} Cleanup complete"
        echo ""
        echo -e "${YELLOW}Removed packages:${NC}"
        echo "$CLEANUP_OUTPUT" | grep "Uninstalling" | sed 's/^/  /'
    else
        echo -e "${GREEN}${SUCCESS}${NC} All packages in sync - nothing to remove"
    fi
    echo ""

    # Install any missing packages
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Installing missing packages from Brewfiles...${NC}"
    brew bundle install --file="$temp_brewfile" --verbose
    echo -e "${GREEN}${SUCCESS}${NC} Brewfile packages synchronized"
    echo ""

    # No need to manually remove, trap will handle it
fi

# Update Oh My Zsh
if [[ -d "$HOME/.oh-my-zsh" ]]; then
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Updating Oh My Zsh...${NC}"
    (cd "$HOME/.oh-my-zsh" && git pull)
    echo -e "${GREEN}${SUCCESS}${NC} Oh My Zsh updated"
    echo ""
fi

# Update zsh-lazyload plugin
if [[ -d "$HOME/.oh-my-zsh/custom/plugins/zsh-lazyload" ]]; then
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Updating zsh-lazyload plugin...${NC}"
    (cd "$HOME/.oh-my-zsh/custom/plugins/zsh-lazyload" && git pull)
    echo -e "${GREEN}${SUCCESS}${NC} zsh-lazyload updated"
    echo ""
fi

# Update Neovim plugins
echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Updating Neovim plugins...${NC}"
if command -v nvim &> /dev/null; then
    echo -e "${YELLOW}${INFO}${NC} Opening Neovim to update plugins (will close automatically)"
    echo -e "${YELLOW}${INFO}${NC} This may take a moment..."
    nvim --headless "+Lazy! sync" +qa 2>/dev/null || true
    echo -e "${GREEN}${SUCCESS}${NC} Neovim plugins updated"
else
    echo -e "${YELLOW}${WARNING}${NC} Neovim not found, skipping plugin update"
fi
echo ""

# Update SDKMAN
if [[ -d "$HOME/.sdkman" ]]; then
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Updating SDKMAN...${NC}"
    source "$HOME/.sdkman/bin/sdkman-init.sh"
    sdk selfupdate || true
    sdk update || true
    echo -e "${GREEN}${SUCCESS}${NC} SDKMAN updated"
    echo ""
fi

# Update NVM and Node.js
if [[ -d "$HOME/.nvm" ]]; then
    echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Checking Node.js LTS...${NC}"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$(brew --prefix)/opt/nvm/nvm.sh" ] && \. "$(brew --prefix)/opt/nvm/nvm.sh"

    if command -v nvm &> /dev/null; then
        CURRENT_LTS=$(nvm version-remote --lts)
        INSTALLED_LTS=$(nvm version lts/* 2>/dev/null || echo "none")

        if [[ "$CURRENT_LTS" != "$INSTALLED_LTS" ]]; then
            echo -e "${YELLOW}${INFO}${NC} New LTS available: $CURRENT_LTS (you have: $INSTALLED_LTS)"
            read -p "$(echo -e ${CYAN}Install latest LTS? [y/N]: ${NC})" yn
            case $yn in
                [Yy]* )
                    nvm install --lts --reinstall-packages-from=current
                    nvm alias default lts/*
                    echo -e "${GREEN}${SUCCESS}${NC} Node.js LTS updated to $CURRENT_LTS"
                    ;;
                * )
                    echo -e "${YELLOW}${WARNING}${NC} Keeping current version"
                    ;;
            esac
        else
            echo -e "${GREEN}${SUCCESS}${NC} Node.s LTS is up to date: $INSTALLED_LTS"
        fi
    fi
    echo ""
fi

# Clean up Homebrew
echo -e "${BOLD}${BLUE}${ARROW}${NC} ${BOLD}Cleaning up Homebrew...${NC}"
brew cleanup
echo -e "${GREEN}${SUCCESS}${NC} Cleanup complete"
echo ""

# Summary
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}Update Complete!${NC}"
echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo -e "${BOLD}What was updated:${NC}"
echo -e "  ${GREEN}${SUCCESS}${NC} dotfiles repository (if changes were available)"
echo -e "  ${GREEN}${SUCCESS}${NC} Homebrew and all packages"
echo -e "  ${GREEN}${SUCCESS}${NC} Oh My Zsh and custom plugins"
echo -e "  ${GREEN}${SUCCESS}${NC} Neovim plugins"
echo -e "  ${GREEN}${SUCCESS}${NC} SDKMAN"
echo -e "  ${GREEN}${SUCCESS}${NC} Node.js (if you chose to update)"
echo ""
echo -e "${BOLD}${CYAN}Note:${NC} Your configs are symlinked from ${YELLOW}$DOTFILES_DIR${NC}"
echo -e "  ${INFO} Edit configs in this repo, then commit and push to keep in sync"
echo -e "  ${INFO} Changes are immediately reflected (no need to copy files)"
echo ""
echo -e "${BOLD}Reminder:${NC}"
echo -e "  ${YELLOW}sdk list java${NC}   - Check for new Java versions"
echo -e "  ${YELLOW}pyenv install --list${NC} - Check for new Python versions"
echo ""