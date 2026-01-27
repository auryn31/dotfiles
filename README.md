# Mac Setup with Homebrew

This repository contains a complete automated setup for your Mac development environment, including Homebrew packages, Neovim with LazyVim, shell configurations, and all necessary tools.

## ✨ Features

- 🎨 **Beautiful CLI output** with colors and progress indicators
- 🔄 **Idempotent** - safe to run multiple times
- 🛡️ **Safe defaults** - backs up existing configurations
- 📦 **All-in-one** - complete development environment in one command
- ⚡ **Fast** - parallelized installations where possible
- 🔗 **Symlinked configs** - all dotfiles tracked in this repo and symlinked to home directory

## 📋 Quick Reference

```bash
./setup.sh [--work|--private]    # First-time setup (run once)
./update.sh [--work|--private]   # Update everything (run regularly)
./doctor.sh                      # Check installation health
```

## 🚀 Quick Start (Automated Setup)

For a fully automated installation of everything:

```bash
# Clone this repository to a persistent location
git clone https://github.com/auryn31/dotfiles.git ~/coding/dotfiles
cd ~/coding/dotfiles

# Run the setup script
./setup.sh

**Note:** You can specify a profile to install additional packages:
- `./setup.sh --work` to install packages from `Brewfile` and `Brewfile.work`.
- `./setup.sh --private` to install packages from `Brewfile` and `Brewfile.private`.
If no profile is specified, only packages from `Brewfile` will be installed.
```

**Important:** Clone to `~/coding/dotfiles` (or another permanent location). The repository must remain in place because all configs are symlinked from `dotfiles/` to your home directory.

This single command will:
- Install Xcode Command Line Tools
- Install Homebrew
- Install all packages from the Brewfile
- Set up Oh My Zsh with plugins (including zsh-lazyload)
- Symlink all configurations from `dotfiles/` directory (zsh, neovim, wezterm, git)
- Configure NVM and install Node.js LTS
- Install and configure SDKMAN for Java management
- Set up shell tools (atuin, direnv, fzf)
- Configure Git
- Create a secure ~/.secrets file template
- Apply recommended macOS defaults

### What Gets Installed

**Development Tools & Languages:**
- Git, GitHub CLI, Git LFS, Lazygit
- Docker & Docker Desktop, Lazydocker
- Kubernetes (kubectl, Helm, k9s)
- Go, Elixir, Erlang, Gleam, Elm
- Java via SDKMAN (Gradle, Maven via Brewfile)
- Node.js via NVM

**Modern CLI Tools:**
- eza (modern ls replacement)
- bat (better cat with syntax highlighting)
- ripgrep, fzf, jq
- htop, tree, tmux
- atuin (better shell history)
- direnv (per-directory environment variables)
- stow (dotfile manager)

**Cloud & DevOps:**
- Google Cloud SDK
- Kubernetes CLI with completion
- Docker & Lazydocker

**Applications:**
- WezTerm (GPU-accelerated terminal)
- Raycast (productivity)
- Docker Desktop
- Magnet (window management, via App Store)
- HiddenBar (menu bar management)

**Shell Configuration:**
- Zsh with Oh My Zsh
- Eastwood theme
- zsh-autosuggestions
- zsh-syntax-highlighting
- zsh-lazyload (for performance)
- Symlinked .zshrc configuration from this repo
- Neovim with LazyVim configuration included in this repo

**VSCode Extensions:**
- Full suite of language support and productivity tools (see Brewfile)

---

## 📦 Manual Installation (Advanced)

If you prefer to install components manually or already have Homebrew installed:

### Prerequisites

Install Homebrew if you haven't already:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Apply the Brewfile

From this directory:
```bash
brew bundle --file=.Brewfile
```

Or specify the full path:
```bash
brew bundle --file=/Users/auryn/coding/dotfiles/.Brewfile
```

### Dry Run (Check what would be installed)

```bash
brew bundle --file=.Brewfile --no-lock check
```

### Install and cleanup (remove packages not in Brewfile)

```bash
brew bundle --file=.Brewfile --cleanup
```

**Note:** The `update.sh` script automatically runs with `--cleanup` to keep your system in sync with the Brewfile. This removes any manually installed packages that aren't tracked in the Brewfile.

---

## 🔄 Updating Everything

To update all components of your development environment:

```bash
./update.sh [--work|--private]
```
**Note:** Specify `--work` or `--private` to update packages for a specific profile (from `Brewfile` and `Brewfile.work` or `Brewfile.private`). If no profile is specified, only packages from the base `Brewfile` will be considered.

This will:
- Pull latest changes from this repository
- Verify all symlinks are properly configured
- Update Homebrew and all packages
- **Remove packages NOT in the selected Brewfiles** (keeps everything in sync)
- Update Oh My Zsh and custom plugins
- Update Neovim plugins
- Update SDKMAN
- Update Node.js to latest LTS
- Clean up old package versions

**Note:** Since configs are symlinked, changes made to files in `dotfiles/` are immediately reflected. The update script verifies symlinks are still properly configured.

### Manual Updates

**Update only Homebrew packages:**
```bash
brew update && brew upgrade
```

**Regenerate Brewfile from current installation:**

If you install new tools and want to update the Brewfile:
```bash
brew bundle dump --file=.Brewfile --force
```

**Sync your system with the Brewfile:**

Check what's different:
```bash
brew bundle check --file=.Brewfile
```

Install missing packages:
```bash
brew bundle --file=.Brewfile
```

---

## 🏥 Health Check

To verify your environment is properly configured:

```bash
./doctor.sh
```

This will check:
- All required tools are installed
- Configurations are present
- Shell integrations are working
- Applications are installed
- SDKMAN and NVM are configured

Use this to diagnose issues after installation or updates.

---

## 📁 Repository Structure

```
.
├── Brewfile               # Base Homebrew package definitions
├── Brewfile.work          # Work-specific Homebrew package definitions
├── Brewfile.private       # Private-specific Homebrew package definitions
├── .gitignore             # Git ignore rules
├── dotfiles/              # All configuration files (symlinked to home)
│   ├── nvim/              # Neovim/LazyVim configuration
│   ├── zsh/.zshrc         # Zsh configuration
│   ├── wezterm/.wezterm.lua  # WezTerm terminal configuration
│   └── git/.gitconfig     # Git configuration (optional)
├── setup.sh               # Automated setup script (run once)
├── update.sh              # Update all components (run regularly)
├── doctor.sh              # Health check script (troubleshooting)
├── ANALYSIS.md            # Setup analysis and decisions
└── README.md              # This file
```

## Scripts Overview

| Script | Purpose | When to Use |
|--------|---------|-------------|
| `setup.sh` | Complete initial setup | First time on new Mac |
| `update.sh` | Update all components | Weekly/monthly maintenance |
| `doctor.sh` | Health check | Troubleshooting issues |

---

## 🔧 Configuration Management

### Symlinked Dotfiles

All configurations are stored in the `dotfiles/` directory and **symlinked** to your home directory. This means:

- **Changes are immediate** - Edit files in this repo, and they're instantly active
- **Everything is tracked** - All configs are version-controlled
- **Easy to sync** - Commit and push to keep configs in sync across machines
- **No copying needed** - Symlinks mean you only edit one location

**Included configurations:**

- **`dotfiles/zsh/.zshrc`** → `~/.zshrc` - Shell configuration
- **`dotfiles/wezterm/.wezterm.lua`** → `~/.wezterm.lua` - Terminal configuration
- **`dotfiles/nvim/`** → `~/.config/nvim` - Neovim/LazyVim configuration
- **`dotfiles/git/.gitconfig`** → `~/.gitconfig` - Git configuration (optional)

### Workflow for Editing Configs

The recommended workflow is:

```bash
# 1. Edit config in this repository
cd ~/coding/dotfiles
nvim dotfiles/zsh/.zshrc

# 2. Test your changes (they're already active via symlink!)
source ~/.zshrc

# 3. Commit and push to version control
git add dotfiles/zsh/.zshrc
git commit -m "Update zsh aliases"
git push
```

Since configs are symlinked, changes are immediately reflected - no need to copy files or run update scripts!

### Secrets Management

The setup creates `~/.secrets` for sensitive environment variables:

```bash
# Edit your secrets file
nvim ~/.secrets

# Add your tokens (example):
export GITHUB_PAT="your_token_here"
export GOOGLE_CLOUD_PROJECT="your-project-id"
```

**Important:**
- `~/.secrets` is sourced by .zshrc
- This file is **never** committed to git
- Use direnv for project-specific secrets

---

## 🍵 Java Management with SDKMAN

SDKMAN manages Java and JVM ecosystem tools:

```bash
# List available Java versions
sdk list java

# Install a specific version
sdk install java 21.0.1-tem

# Switch Java version
sdk use java 21.0.1-tem

# Set default Java version
sdk default java 21.0.1-tem

# Install other JVM tools
sdk install kotlin
sdk install scala
```

Gradle and Maven are installed via Homebrew for convenience, but you can also install them via SDKMAN if preferred.

---

## 📦 Node.js with NVM

NVM manages multiple Node.js versions:

```bash
# Install latest LTS
nvm install --lts

# Install specific version
nvm install 20

# Switch versions
nvm use 20

# Set default version
nvm alias default 20

# List installed versions
nvm list
```

Node is lazy-loaded via zsh-lazyload for faster shell startup.

---

## 🎨 Aliases & Tools

Your setup includes modern CLI alternatives:

```bash
ls    # → eza (colorful, with icons)
ll    # → eza -la
lt    # → eza --tree
cat   # → bat (syntax highlighting)
vim   # → nvim
k     # → kubectl
```

---

## Post-Setup Tasks

After running `./setup.sh`, complete these manual steps:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Open Neovim** (`nvim`) to trigger LazyVim plugin installation
3. **Sign in to Mac App Store** to install Magnet: `mas install 441258766`
4. **Launch Docker Desktop** and accept the license agreement
5. **Configure Raycast** in System Preferences → Extensions
6. **Add your credentials** to `~/.secrets`
7. **Install Java** (optional): `sdk install java 21.0.1-tem`

---

## Troubleshooting

### Setup Script Issues

**Script stops at Xcode tools:**
- Complete the Xcode Command Line Tools installation
- Run `./setup.sh` again

**Homebrew permission issues:**
```bash
sudo chown -R $(whoami) $(brew --prefix)/*
```

**Oh My Zsh installation fails:**
- Check if `~/.oh-my-zsh` already exists
- Remove it and run the script again: `rm -rf ~/.oh-my-zsh`

### Homebrew Issues

**Check for problems:**
```bash
brew doctor
```

**Force reinstall a package:**
```bash
brew reinstall <package-name>
```

**Update outdated packages:**
```bash
brew update && brew upgrade
```

### Neovim/LazyVim Issues

**Plugins not installing:**
- Open Neovim: `nvim`
- Run `:Lazy sync`

**Symlink broken or config issues:**
```bash
# Re-run setup to recreate symlink
./setup.sh

# Or manually fix the symlink
rm ~/.config/nvim
ln -s ~/coding/dotfiles/dotfiles/nvim ~/.config/nvim
```

### NVM/Node Issues

**Node not found after installation:**
```bash
# Source NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"

# Install Node LTS
nvm install --lts
nvm use --lts
```

### SDKMAN/Java Issues

**SDKMAN not found:**
```bash
# Source SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
source "$HOME/.sdkman/bin/sdkman-init.sh"

# Install Java
sdk install java 21.0.1-tem
```

---

## Notes

- **Repository Location**: Keep this repo at `~/coding/dotfiles` (or update paths if moved) - configs are symlinked from here
- **Symlinked Configs**: All dotfiles are symlinked, not copied - changes in this repo are immediately reflected
- **NVM**: Node versions are managed via nvm (in `~/.nvm`), not Homebrew, allowing multiple versions
- **SDKMAN**: Java/JVM tools managed via SDKMAN, Gradle/Maven available via Homebrew
- **Magnet**: Installed via Mac App Store (requires being signed in)
- **Docker Desktop**: Requires manual license acceptance on first launch
- **Idempotent**: The setup script can be run multiple times safely - it checks for existing installations
- **Secrets**: Never commit `~/.secrets` - use it for sensitive environment variables

---

## Key Decisions

This setup is configured with the following choices:

✅ **Dotfiles Management**: Symlink-based approach - all configs in `dotfiles/` directory
✅ **Neovim Config**: Included in this repository (no separate clone needed)
✅ **Java Management**: SDKMAN only (removed jenv)
✅ **ls Tool**: eza (removed lsd)
✅ **Node Manager**: NVM at `~/.nvm`
✅ **Package Manager**: npm via Node (removed yarn)
✅ **No Haskell**: ghcup not installed

See `ANALYSIS.md` for detailed rationale.

---

## Contributing

This is a personal setup, but feel free to fork and customize for your needs!

## Related Repositories

- [auryn31/mac-dev-setup](https://github.com/auryn31/mac-dev-setup) - Previous setup scripts
