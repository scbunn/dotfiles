#!/bin/sh
# Make this user's cellar share automount on macOS (Sequoia+). Needs sudo; idempotent.
# Run once per user; each user adds a line to the shared /etc/auto_nfs.
# macOS has a read-only root, so /cellar is a synthetic symlink to a real
# directory on the Data volume, and automount works on that real path.
set -eu
. "$(dirname "$0")/nfs.conf"

real=/System/Volumes/Data/mnt/cellar
map=/etc/auto_nfs

sudo mkdir -p "$real"

# /cellar -> System/Volumes/Data/mnt/cellar (synthetic.conf is tab separated;
# appears after a reboot).
if ! grep -q '^cellar	' /etc/synthetic.conf 2>/dev/null; then
  printf 'cellar\tSystem/Volumes/Data/mnt/cellar\n' | sudo tee -a /etc/synthetic.conf >/dev/null
fi

# Direct map: one line per user. nobrowse (in auto_master) keeps it out of Finder.
sudo touch "$map"
if ! grep -q "^$real/$USER[[:space:]]" "$map"; then
  printf '%s\t-fstype=nfs,vers=4,nosuid,nodev\tnfs://%s%s\n' \
    "$real/$USER" "$NAS_HOST" "$NAS_USER_PATH" | sudo tee -a "$map" >/dev/null
fi

if ! grep -q '^/-[[:space:]]*auto_nfs' /etc/auto_master; then
  printf '/-\t\t\tauto_nfs\t-nobrowse,nosuid\n' | sudo tee -a /etc/auto_master >/dev/null
fi

sudo automount -cv
echo "Reboot once so /cellar appears, then: ls /cellar/$USER"
echo "Note: macOS updates can rewrite /etc/auto_master; re-run this script if mounts vanish."
