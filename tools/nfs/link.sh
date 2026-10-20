#!/bin/sh
# Point ~/Documents etc. at the cellar mounts. Never deletes anything: a real,
# non-empty directory is left alone and reported (migrate it first, see docs/nfs.md).
set -eu
. "$(dirname "$0")/nfs.conf"

link() { # name target
  name=$1 target=$2 path=$HOME/$1
  if [ -L "$path" ]; then
    [ "$(readlink "$path")" = "$target" ] && return 0
    ln -sfn "$target" "$path"; echo "relinked $path"; return 0
  fi
  if [ -e "$path" ]; then
    if [ -d "$path" ] && [ -z "$(ls -A "$path" 2>/dev/null)" ]; then
      rmdir "$path"
    else
      echo "SKIP $path: real directory with contents; migrate it first" >&2; return 0
    fi
  fi
  ln -s "$target" "$path"; echo "linked $path -> $target"
}

[ -d "$MNT_ROOT/$USER" ] && ls "$MNT_ROOT/$USER" >/dev/null 2>&1 || { echo "$MNT_ROOT/$USER not mounted; aborting" >&2; exit 1; }

link Documents "$MNT_ROOT/$USER/Documents"
link Downloads "$MNT_ROOT/$USER/Downloads"
link Pictures  "$MNT_ROOT/$USER/Pictures"
link Music     "$MNT_ROOT/media/Music"
case "$(uname)" in
  Darwin) link Movies "$MNT_ROOT/media/Movies" ;;
  *)      link Videos "$MNT_ROOT/media/Movies" ;;
esac
# Desktop and Library are deliberately never linked.
