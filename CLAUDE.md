# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

This is a macOS development environment setup repository that automates the installation and configuration of a complete development stack using Homebrew, shell configurations, and symlinked dotfiles. All configurations are stored in the `dotfiles/` directory and symlinked to the home directory, making changes immediately reflected and easily version-controlled. It provides idempotent setup scripts for new Mac machines and regular updates.

## Key Scripts & Commands

### Primary Commands
- `./setup.sh` - Initial setup (run once on new machine). Installs Homebrew, packages, Oh My Zsh, symlinks all dotfiles, sets up SDKMAN, NVM, and configures shell
- `./update.sh` - Update all components (run regularly). Pulls repo updates, verifies symlinks, updates Homebrew packages, runs `brew bundle cleanup` to remove non-Brewfile packages, updates Oh My Zsh
- `./doctor.sh` - Health check and diagnostic script. Verifies all tools, configurations, and symlinks are properly set up

### Homebrew Operations
- `brew bundle --file=.Brewfile` - Install packages from Brewfile
- `brew bundle --file=.Brewfile --cleanup` - Install and remove packages not in Brewfile
- `brew bundle dump --file=.Brewfile --force` - Regenerate Brewfile from current installation

### Testing & Development
When modifying scripts:
- Test setup.sh on a fresh macOS installation or in a VM
- Ensure idempotency - scripts should be safe to run multiple times
- Test that existing installations are backed up before replacement
- Verify that all paths work for both Homebrew installed tools and manual installations

## Architecture & Design

### Script Structure
All three main scripts (`setup.sh`, `update.sh`, `doctor.sh`) follow a consistent pattern:
- Color-coded output functions (print_header, print_step, print_success, print_error)
- Idempotent operations with existence checks
- Backup creation before overwriting configurations
- User prompts for destructive operations

### Configuration Management Strategy

**Symlinked Dotfiles** (version-controlled in `dotfiles/`):
- `dotfiles/zsh/.zshrc` → `~/.zshrc` - Shell configuration
- `dotfiles/wezterm/.wezterm.lua` → `~/.wezterm.lua` - Terminal configuration
- `dotfiles/nvim/` → `~/.config/nvim` - Neovim/LazyVim configuration
- `dotfiles/git/.gitconfig` → `~/.gitconfig` - Git configuration (optional)

**Symlink-Based Approach**:
1. All configs are stored in repo under `dotfiles/`
2. During setup, symlinks are created from `dotfiles/` to home directory
3. Changes made to files in this repo are immediately reflected (no copying needed)
4. `update.sh` verifies symlinks are properly configured
5. User's existing configs are backed up with timestamp before symlinking
6. Workflow: edit in repo → test immediately → commit → push to sync

### Secrets Management
- `~/.secrets` file is created during setup for sensitive environment variables
- Sourced by .zshrc if it exists
- **Never committed to git** - template only is created
- User must manually add tokens/credentials after setup

### Tool Management Decisions

**Java/JVM**: SDKMAN only
- setup.sh:140-141 sources SDKMAN
- Gradle and Maven installed via Homebrew (not SDKMAN) for convenience
- jenv was removed to avoid conflicts

**Node.js**: NVM at `~/.nvm`
- Lazy-loaded via zsh-lazyload for performance (configs/.zshrc:64)
- Supports both manual install (`~/.nvm/nvm.sh`) and Homebrew install locations
- npm is the package manager (yarn removed)

**ls replacement**: eza
- lsd was replaced with eza (more modern, actively maintained)
- Aliases in configs/.zshrc:31-35

**Python**: pyenv (installed via Homebrew)

**Google Cloud SDK**:
- Can be installed via Homebrew (preferred) or manually
- .zshrc checks both locations (configs/.zshrc:82-88)

### zsh-lazyload Plugin
- Custom Oh My Zsh plugin, not in Homebrew
- Installed manually via git clone in setup.sh
- Critical for performance - lazy-loads NVM to speed up shell startup
- Located at `~/.oh-my-zsh/custom/plugins/zsh-lazyload`

## Important Development Notes

### When Modifying setup.sh
1. **Xcode Command Line Tools**: Check is non-blocking - user must complete installation manually if triggered
2. **Oh My Zsh**: Installation via their official script, skips if already exists
3. **Dotfiles Symlinking**: Uses `safe_symlink()` function to create symlinks with backup
4. **Neovim Config**: Now included in `dotfiles/nvim/` directory (no separate clone)
5. **File Operations**: Always create backups before replacing configs or creating symlinks
6. **macOS Defaults**: Applied at end of script (dock position, show hidden files, etc.)

### When Modifying .Brewfile
- Run `brew bundle dump --file=.Brewfile --force` to regenerate from current installation
- Include comments for context (see existing format)
- VSCode extensions use `vscode "publisher.extension-name"` format
- Mac App Store apps use `mas "AppName", id: 12345` format
- Note: Running `update.sh` will **remove any packages not in Brewfile** via cleanup mode

### When Modifying dotfiles/zsh/.zshrc
- Structure is organized into sections
- Plugin sources: Homebrew-installed plugins sourced from `$(brew --prefix)/share/`
- Lazy-loading: NVM and other slow tools use `lazyload` for performance
- Path checks: All tool integrations check for existence before sourcing
- Symlinked file: Changes are immediately reflected since `~/.zshrc` is a symlink
- Version control: Commit changes to this file to keep configs in sync across machines

### Security Considerations
- Never add secrets/tokens to version-controlled files
- The old .zshrc had GitHub PAT tokens exposed (see ANALYSIS.md) - this has been fixed
- `~/.secrets` pattern is the correct approach for credentials
- `.npmrc` credentials should not be written on every shell startup

## File Locations & Paths

**Installed by Setup**:
- `~/.oh-my-zsh/` - Oh My Zsh installation
- `~/.oh-my-zsh/custom/plugins/zsh-lazyload/` - Custom performance plugin
- `~/.nvm/` - Node Version Manager
- `~/.sdkman/` - SDKMAN for Java/JVM tools
- `~/.pyenv/` - Python version manager
- `~/.atuin/` - Shell history tool
- `~/.secrets` - User credentials file (created empty, user must populate)

**Symlinked Configuration Files** (from this repo):
- `~/.zshrc` → `dotfiles/zsh/.zshrc` - Shell config
- `~/.wezterm.lua` → `dotfiles/wezterm/.wezterm.lua` - Terminal config
- `~/.config/nvim/` → `dotfiles/nvim/` - Neovim/LazyVim config
- `~/.gitconfig` → `dotfiles/git/.gitconfig` - Git configuration (optional)

## Language & Framework Specifics

**Go**:
- Installed via Homebrew
- `GOPATH/bin` added to PATH in .zshrc:70
- `gopls` language server installed

**Elixir/Erlang**:
- Installed via Homebrew
- `elixir-ls` and `erlang_ls` language servers included
- Erlang installed as dependency of Elixir

**Gleam**:
- Installed via Homebrew
- Built for Erlang VM

**Elm**:
- Installed via Homebrew
- VSCode extension and language support included

**Python**:
- Managed via pyenv
- poetry and pipx included for package management
- Jupyter extensions in VSCode

**Java**:
- Install via SDKMAN: `sdk install java 21.0.1-tem`
- Gradle and Maven available via Homebrew
- google-java-format included for code formatting

**Docker**:
- Docker Desktop installed via cask
- lazydocker for terminal UI
- User must accept license on first launch

**Kubernetes**:
- kubectl with zsh completion enabled
- Helm package manager
- k9s for cluster management
- Alias: `k` → `kubectl`

## Common Patterns

### Adding New Homebrew Package
1. Install manually: `brew install package-name`
2. Test it works as expected
3. Add to `.Brewfile`: `brew "package-name"`
4. Or regenerate entire Brewfile: `brew bundle dump --file=.Brewfile --force`
5. Note: Next time someone runs `update.sh`, packages not in Brewfile will be removed

### Adding New VSCode Extension
1. Install in VSCode or: `code --install-extension publisher.extension-name`
2. Add to `.Brewfile`: `vscode "publisher.extension-name"`
3. Or use `brew bundle dump` to capture all installed extensions

### Updating Shell Configuration
1. Edit `dotfiles/zsh/.zshrc` in the repository
2. Changes are immediately active (file is symlinked)
3. Test changes: `source ~/.zshrc`
4. Commit the changes: `git add dotfiles/zsh/.zshrc && git commit -m "Update zshrc"`
5. Push to sync across machines: `git push`

### Troubleshooting User Issues
1. Run `./doctor.sh` to check installation health
2. Check if tools are in PATH: `which <tool>`
3. For shell integration issues: source the config: `source ~/.zshrc`
4. For Homebrew permission issues: `sudo chown -R $(whoami) $(brew --prefix)/*`
5. For plugin issues: Check if properly sourced in .zshrc and files exist

## Post-Setup Manual Steps

Users must complete these after running `./setup.sh`:
1. Restart terminal or `source ~/.zshrc`
2. Open Neovim (`nvim`) to trigger LazyVim plugin installation
3. Sign into Mac App Store for Magnet installation
4. Launch Docker Desktop and accept license
5. Configure Raycast in System Preferences
6. Add credentials to `~/.secrets`
7. Install Java if needed: `sdk install java 21.0.1-tem`
