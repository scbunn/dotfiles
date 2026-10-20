#!/bin/sh
# Point ~/Documents and ~/Downloads at this user's cellar share. Never deletes
# anything: a real, non-empty directory is left alone and reported (migrate it
# first, see docs/nfs.md).
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

ls "$MNT_ROOT/$USER" >/dev/null 2>&1 || { echo "$MNT_ROOT/$USER not mounted; aborting" >&2; exit 1; }
for d in Documents Downloads; do
  [ -d "$MNT_ROOT/$USER/$d" ] || { echo "missing $MNT_ROOT/$USER/$d on the NAS; create it first" >&2; exit 1; }
done
link Documents "$MNT_ROOT/$USER/Documents"
link Downloads "$MNT_ROOT/$USER/Downloads"
# Never linked: Desktop and Library (iCloud / app state), Pictures, Music, Movies.
