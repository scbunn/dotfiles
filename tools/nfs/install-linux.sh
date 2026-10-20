#!/bin/sh
# Automount the cellar NFS shares on Linux via fstab + systemd automount. Needs sudo; idempotent.
# Client packages: nfs-common (apt), nfs-utils (dnf, pacman). fsc needs cachefilesd.
set -eu
. "$(dirname "$0")/nfs.conf"

opts="nfs4 _netdev,noauto,nofail,x-systemd.automount,x-systemd.idle-timeout=600,x-systemd.mount-timeout=10,noatime,nosuid,nodev,fsc 0 0"

sudo mkdir -p "$MNT_ROOT/$USER" "$MNT_ROOT/media"

add() {
  grep -q " $2 " /etc/fstab || printf '%s:%s %s %s\n' "$NAS_HOST" "$1" "$2" "$opts" | sudo tee -a /etc/fstab >/dev/null
}
add "$NAS_USER_PATH" "$MNT_ROOT/$USER"
add "$NAS_MEDIA_PATH" "$MNT_ROOT/media"

# FS-Cache: local disk cache for NFS reads. Package is cachefilesd everywhere;
# on Fedora/Arch enable the service, on Debian also set RUN=yes in /etc/default/cachefilesd.
if command -v systemctl >/dev/null && systemctl list-unit-files cachefilesd.service >/dev/null 2>&1; then
  sudo systemctl enable --now cachefilesd || true
else
  echo "cachefilesd not installed: mounts will work, just without the local read cache."
fi

sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target
echo "Test: ls $MNT_ROOT/$USER"
