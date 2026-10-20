# =========================================================
# Plugins
# =========================================================

ZPLUGINDIR="${ZDOTDIR:-$HOME/.config/zsh}/plugins"

_zplugin_load() {
  local plugin_path="${ZPLUGINDIR}/${2}"
  if [[ ! -d "$plugin_path" ]]; then
    mkdir -p "$ZPLUGINDIR"
    echo "Installing ${2}..."
    git clone --depth=1 "https://github.com/${1}/${2}" "$plugin_path" \
      || { echo "ERROR: failed to install ${2}" >&2; return 1; }
  fi
  source "${plugin_path}/${2}.plugin.zsh"
}

zplugin-update() {
  local dir
  for dir in "${ZPLUGINDIR}"/*/; do
    echo "Updating ${dir:t}..."
    git -C "$dir" pull --ff-only
  done
}

# fzf-tab: must load after compinit (done in .zshrc) and BEFORE plugins that wrap
# widgets (autosuggestions, syntax highlighting)
_zplugin_load Aloxaf fzf-tab
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'

# Turn fzf-tab off for specific commands (falls back to normal zsh completion):
#   zstyle ':fzf-tab:complete:git:*' disabled-on any
# Or toggle it live in a shell: toggle-fzf-tab

_zplugin_load zsh-users zsh-autosuggestions
_zplugin_load zsh-users zsh-history-substring-search
_zplugin_load jeffreytse zsh-vi-mode
_zplugin_load zdharma-continuum fast-syntax-highlighting
