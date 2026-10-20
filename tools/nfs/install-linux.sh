#!/bin/sh
# Automount this user's cellar share on Linux via fstab + systemd automount. Needs sudo; idempotent.
# Client packages: nfs-common (apt), nfs-utils (dnf, pacman). Optional read cache: cachefilesd.
set -eu
. "$(dirname "$0")/nfs.conf"

opts="nfs4 _netdev,noauto,nofail,x-systemd.automount,x-systemd.idle-timeout=600,x-systemd.mount-timeout=10,noatime,nosuid,nodev,fsc 0 0"
mnt=$MNT_ROOT/$USER

sudo mkdir -p "$mnt"
grep -q " $mnt " /etc/fstab || printf '%s:%s %s %s\n' "$NAS_HOST" "$NAS_USER_PATH" "$mnt" "$opts" | sudo tee -a /etc/fstab >/dev/null

# FS-Cache: local disk cache for NFS reads (the fsc option). Without cachefilesd
# running, mounts still work, just uncached. Debian also needs RUN=yes in /etc/default/cachefilesd.
if systemctl list-unit-files cachefilesd.service 2>/dev/null | grep -q cachefilesd; then
  sudo systemctl enable --now cachefilesd || true
else
  echo "cachefilesd not installed: mounts work, without the local read cache."
fi

sudo systemctl daemon-reload
sudo systemctl restart remote-fs.target
echo "Test: ls $mnt"
