#!/bin/sh
# Make the cellar NFS shares automount on macOS (Sequoia+). Needs sudo; idempotent.
# macOS has a read-only root, so /cellar is a synthetic symlink to a real
# directory on the Data volume, and automount works on that real path.
set -eu
. "$(dirname "$0")/nfs.conf"

real=/System/Volumes/Data/mnt/cellar
map=/etc/auto_nfs

sudo mkdir -p "$real"

# /cellar -> System/Volumes/Data/mnt/cellar (synthetic.conf is tab separated;
# first appears after a reboot, or `apfs.util -t`).
if ! grep -q '^cellar	' /etc/synthetic.conf 2>/dev/null; then
  printf 'cellar\tSystem/Volumes/Data/mnt/cellar\n' | sudo tee -a /etc/synthetic.conf >/dev/null
fi

# Direct map, one line per share. resvport is required by macOS's NFS client
# with some servers; nobrowse keeps it out of Finder's sidebar.
sudo tee "$map" >/dev/null <<MAP
$real/$USER	-fstype=nfs,vers=4,resvport,nosuid,nodev	nfs://$NAS_HOST$NAS_USER_PATH
$real/media	-fstype=nfs,vers=4,resvport,nosuid,nodev	nfs://$NAS_HOST$NAS_MEDIA_PATH
MAP

if ! grep -q '^/-[[:space:]]*auto_nfs' /etc/auto_master; then
  printf '/-\t\t\tauto_nfs\t-nobrowse,nosuid\n' | sudo tee -a /etc/auto_master >/dev/null
fi

sudo automount -cv
echo "Reboot once (or run: sudo /System/Library/Filesystems/apfs.fs/Contents/Resources/apfs.util -t) so /cellar appears."
echo "Note: macOS updates can rewrite /etc/auto_master; re-run this script if mounts vanish."
