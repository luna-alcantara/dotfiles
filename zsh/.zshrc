
# ----- Environment -----
export EDITOR=nvim
export VISUAL=nvim
export PAGER=less
export BROWSER=firefox

# Paths
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.dotnet/tools:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"

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
alias cz=chezmoi

# Config shortcuts
alias zshc='nvim ~/.zshrc'
alias szsh='source ~/.zshrc'
alias nvimc='cd ~/.config/nvim/ && nvim .'
alias starshipc='nvim ~/.config/starship.toml'
alias tmuxc='nvim ~/.tmux.conf'
alias hyprc='cd ~/.config/hypr/ && nvim .'

eval "$(zoxide init zsh)"
eval "$(starship init zsh)"

