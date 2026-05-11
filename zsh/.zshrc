# Linux
export BROWSER=firefox
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
export NVIM_LLM_PROVIDER=opencode

# WSL
#export BROWSER=explorer.exe
#export DOTNET_ROOT=$HOME/.dotnet
#export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools
#export NVIM_LLM_PROVIDER=kiro

# ----- Environment -----
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less

# Paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="/snap/bin/:$PATH"

# ----- History -----
HISTFILE="$HOME/.zsh_history"
HISTSIZE=10000
SAVEHIST=10000

setopt APPEND_HISTORY
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY

# ----- Completion -----
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select

# ----- Keybindings -----
bindkey -e
bindkey '^R' history-incremental-search-backward

# ----- Aliases -----

# Config shortcuts
alias zshs='source ~/.zshrc'
alias zshc='nvim ~/.zshrc'

alias nvimc='cd ~/.config/nvim/ && nvim .'
alias starshipc='nvim ~/.config/starship.toml'
alias tmuxc='nvim ~/.tmux.conf'
alias hyprc='cd ~/.config/hypr/ && nvim .'
alias stow-arch='cd ~/.dotfiles/arch'
alias stow-dev='cd ~/.dotfiles/dev/'

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
