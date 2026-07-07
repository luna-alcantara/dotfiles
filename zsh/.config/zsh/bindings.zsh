# =========================================================
# Keybindings
# =========================================================

# Cursor shape per vi mode
ZVM_INSERT_MODE_CURSOR=$ZVM_CURSOR_BEAM
ZVM_NORMAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK
ZVM_VISUAL_MODE_CURSOR=$ZVM_CURSOR_BLOCK

# Disable command mode line highlight
ZVM_VI_HIGHLIGHT_BACKGROUND=none
ZVM_VI_HIGHLIGHT_FOREGROUND=none
ZVM_VI_HIGHLIGHT_EXTRASTYLE=none

# Widget wrappers for TUI apps (bindkey needs zle widgets, not raw commands)
_lazygit() { zle -R; lazygit; zle reset-prompt }
zle -N _lazygit

_gh_dash() { zle -R; gh dash; zle reset-prompt }
zle -N _gh_dash

_lazydocker() { zle -R; lazydocker; zle reset-prompt }
zle -N _lazydocker

# zsh-vi-mode resets all bindings on init, so custom bindings
# must be registered via this hook to survive.
zvm_after_init() {
  # Ctrl+Right -> move forward one word (^[[1;5C is the terminal escape code)
  bindkey '^[[1;5C' forward-word

  # Ctrl+Left -> move backward one word (^[[1;5D is the terminal escape code)
  bindkey '^[[1;5D' backward-word

  # Ctrl+F -> fzf file picker (no hidden files)
  bindkey '^F' _fzf_file_no_hidden

  # Ctrl+\ -> toggle autosuggestions (useful for screen recordings)
  bindkey '^\' autosuggest-toggle

  # Ctrl+B -> bookmark picker
  bindkey '^B' _bookmark_fzf

  # Alt+N -> navi cheatsheet
  bindkey '^[n' _navi_widget

  # Ctrl+G -> lazygit
  bindkey '^G' _lazygit

  # Alt+D -> gh-dash
  bindkey '^[d' _gh_dash

  # Alt+C -> lazydocker
  bindkey '^[c' _lazydocker

  # Up/Down -> history search by substring (^[[A/^[[B are up/down arrow escape codes)
  bindkey '^[[A' history-substring-search-up
  bindkey '^[[B' history-substring-search-down
}
