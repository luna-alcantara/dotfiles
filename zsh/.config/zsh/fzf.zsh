# =========================================================
# fzf
# =========================================================

export FZF_DEFAULT_COMMAND='fd --type f --hidden --strip-cwd-prefix'  # strip-cwd-prefix removes the leading ./ from results

# Ctrl-T uses fd
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# UI
export FZF_DEFAULT_OPTS='
  --height=60%
  --layout=reverse
  --border=rounded
  --prompt="  "
  --pointer="  "
  --preview-window=right:65%:wrap:border-left
'

export _FZF_PREVIEW_CMD='bat --color=always --style=plain,numbers --line-range=:500 {}'
export FZF_CTRL_T_OPTS="--preview '$_FZF_PREVIEW_CMD'"

# Ctrl+F: file picker excluding hidden files
_fzf_file_no_hidden() {
  local cmd result
  cmd="${FZF_DEFAULT_COMMAND/--hidden /}"
  result=$(eval "${cmd:-find . -type f}" | fzf --preview "$_FZF_PREVIEW_CMD") \
    && LBUFFER+="$result"  # LBUFFER is the text left of the cursor
  zle reset-prompt
}
zle -N _fzf_file_no_hidden

# Ctrl+B: buku bookmark picker - search and open in browser
_buku_fzf() {
  local result
  result=$(
    buku --nostdin -p --format 40 \
    | awk -F'\t' '{ printf "%s | %s | %s\n", $2, $3, $1 }' \
    | fzf --prompt="buku> "
  )
  if [[ -n "$result" ]]; then
    local url
    local tmp="${result#* | }"   # strip "title | "
    url="${tmp#* | }"            # strip "tags | "
    xdg-open "$url"
  fi
  zle reset-prompt
}
zle -N _buku_fzf
