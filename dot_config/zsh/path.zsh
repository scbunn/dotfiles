# Sourced from .zshenv AND .zprofile: macOS's path_helper reorders PATH in
# login shells, so we set it again afterwards.
typeset -U path PATH
path=(
  "$HOME/bin"
  "$HOME/.local/bin"
  "$GOPATH/bin"
  $path
)
# Separate block: quoted words inside ${VAR:+...} get joined into ONE word
if [[ -n $HOMEBREW_PREFIX ]]; then
  path=(
    "$HOMEBREW_PREFIX/bin"
    "$HOMEBREW_PREFIX/sbin"
    "$HOMEBREW_PREFIX/opt/coreutils/libexec/gnubin"
    $path
  )
fi
[[ -n $HOMEBREW_PREFIX ]] && fpath=("$HOMEBREW_PREFIX/share/zsh/site-functions" $fpath)
# Homebrew's zsh ships its own functions (run-help, etc.)
[[ -n $HOMEBREW_PREFIX ]] && fpath=("$HOMEBREW_PREFIX/opt/zsh/share/zsh/functions" $fpath)
