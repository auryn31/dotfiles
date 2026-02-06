# ============================================
# Oh My Zsh Configuration
# ============================================
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="Eastwood"

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
plugins=(
  git
  brew
  docker
  zsh-lazyload
)

source $ZSH/oh-my-zsh.sh

# ============================================
# Homebrew Plugin Sources
# ============================================
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# ============================================
# Aliases
# ============================================
alias vim="nvim"
alias ls='eza'
alias l='eza -l'
alias la='eza -a'
alias lla='eza -la'
alias lt='eza --tree'
alias cat='bat'

# ============================================
# Shell Tools
# ============================================

# Atuin - better shell history
. "$HOME/.atuin/bin/env"
eval "$(atuin init zsh)"

# Direnv - load environment variables based on directory
eval "$(direnv hook zsh)"

# FZF - fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# ============================================
# Language & Runtime Managers
# ============================================

# SDKMAN - Java/JVM ecosystem manager
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# NVM - Node.js version manager (lazy loaded for performance)
export NVM_DIR="$HOME/.nvm"
# Check for both manual install and Homebrew install
if [[ -s "$NVM_DIR/nvm.sh" ]]; then
  lazyload nvm -- 'source $NVM_DIR/nvm.sh'
elif [[ -s "$(brew --prefix)/opt/nvm/nvm.sh" ]]; then
  lazyload nvm -- 'source $(brew --prefix)/opt/nvm/nvm.sh'
fi

# Go
export PATH=$PATH:$(go env GOPATH)/bin

# Python - pyenv
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# ============================================
# Cloud & DevOps Tools
# ============================================

# Google Cloud SDK (check both Homebrew and manual install locations)
if [ -f "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc" ]; then
  source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
  source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
elif [ -f "$HOME/google-cloud-sdk/path.zsh.inc" ]; then
  source "$HOME/google-cloud-sdk/path.zsh.inc"
  source "$HOME/google-cloud-sdk/completion.zsh.inc"
fi

# Set your default GCP project (customize this)
# export GOOGLE_CLOUD_PROJECT=your-project-id

# Kubernetes
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)
alias k="kubectl"

# ============================================
# Application Paths
# ============================================

export PATH="$HOME/.local/bin:$PATH"

# Fabric (if you use it)
# alias fabric=/Users/auryn/coding/fabric

# ============================================
# Secrets & Environment Variables
# ============================================

# Load secrets from a separate file (never commit this!)
# Create ~/.secrets with your tokens and credentials
# Add it to .gitignore if storing in a dotfiles repo
if [ -f "$HOME/.secrets" ]; then
  source "$HOME/.secrets"
fi

# For direnv users: create .envrc files in project directories
# Example .envrc:
#   export GITHUB_PAT="your-token-here"
#   export DATABASE_URL="postgres://..."

# ============================================
# Terminal Configuration
# ============================================

# Better colors in tmux
[ -z "$TMUX" ] && export TERM=xterm-256color

# ============================================
# Optional: Performance Profiling
# ============================================
# Uncomment to profile shell startup time
# zmodload zsh/zprof
# Add 'zprof' at the end of this file to see results
