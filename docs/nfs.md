# NFS from cellar (TrueNAS Community Edition 25.10 "Goldeye")

Server: `cellar.distillery.taplabs.io`, NFSv4 only. Scripts live in `tools/nfs/`.
Pool: `tank`. Media is deferred; see the last section.

## Layout

```
tank/users                  parent dataset, not shared
tank/users/scbunn           own dataset + NFS share, mode 700: Documents Downloads
tank/users/woosuk           same for the second user
```

Each user's share mounts at `/cellar/<user>` on macOS and Linux, and `~/Documents` and
`~/Downloads` are symlinks into it. Not linked: `~/Desktop` and `~/Library` (iCloud and
app state; iCloud is off and `~/Desktop` must stay a real local folder if it is ever
enabled), and `~/Pictures`, `~/Music`, `~/Movies`.

## User ids

NFS (sec=sys) trusts the numeric uid, so each person needs the same uid on the NAS and on
every machine. Chosen at random, well clear of the system and default ranges:

| user | uid | primary gid |
|------|-----|-------------|
| scbunn | 25607 | 25607 |
| woosuk | 44809 | 44809 |

The group `media` (gid 3000) already exists on the NAS for the shared library; add a user
to it only when media is set up.

### macOS (new users)

Create the account with the uid from the start. The GUI cannot set it, so use
`sysadminctl` (as an admin; prompts for the new user's password):

```sh
sudo sysadminctl -addUser scbunn -fullName "Stephen Bunn" -UID 25607 -password - -home /Users/scbunn
```

Then confirm with `id scbunn`. The primary gid on macOS defaults to 20 (`staff`) and
does not need to match, because the NAS only checks the uid for the share (mode 700,
owner). If you later want a matching gid, create the group first with `dscl`.
macOS uids above 501 are fine; the login window lists the account normally.

### Linux

Check the number is free: `getent passwd 25607` (must be empty).

```sh
sudo groupadd -g 25607 scbunn
sudo useradd -m -u 25607 -g 25607 -s /usr/bin/zsh scbunn      # new machine
```

An existing user at 1000, from a root shell with them logged out (a TTY, or `wsl -u root`):

```sh
usermod -u 25607 scbunn
groupmod -g 25607 scbunn
find / -xdev \( -uid 1000 -o -gid 1000 \) -exec chown -h 25607:25607 {} +   # drop -exec to preview
```

25607 is above 1000, so GDM and SDDM show the account normally.

## 1. TrueNAS (web UI)

Menu names are from SCALE and may differ slightly in Goldeye.

1. Credentials > Local Users > Add, once per person: username, UID from the table,
   "Create New Primary Group" ticked with the group's GID set to the same number
   (if the form lets you), Home Directory none, SMB off. No password login needed.
2. Datasets > `tank` > Add Dataset: `users`, preset Generic. Do not share it.
3. Under `users`, add a dataset per person (`scbunn`, `woosuk`), preset Generic. The
   dataset name must equal the username, because the scripts build the path from `$USER`.
4. For each: Permissions > Edit. User and group = that person, mode `700`, apply recursively.
5. Create the folders `Documents` and `Downloads` inside each (Permissions page has no
   mkdir; use the TrueNAS shell, or create them from the Mac once it is mounted).
6. Shares > UNIX (NFS) Shares > Add, once per person:
   - Path `/mnt/tank/users/<name>`
   - Advanced Options: Networks = your LAN subnet only. Leave Maproot and Mapall empty.
7. System > Services > NFS: enable NFSv4, start, Start Automatically on. Leave NFSv3 off.

Optional: a quota on each user dataset and a periodic snapshot task.

## 2. Mount (per machine, per user)

- **macOS:** `tools/nfs/install-macos.sh` as that user (uses sudo). It adds that user's line
  to `/etc/auto_nfs`, an `auto_master` entry, and the `/cellar` synthetic link. Reboot once.
  macOS updates can rewrite `/etc/auto_master`; re-run the script if the mount disappears.
- **Linux:** install `nfs-common` (apt) or `nfs-utils` (dnf, pacman), optionally
  `cachefilesd`, then `tools/nfs/install-linux.sh`. Mounts lazily via systemd automount.
- **WSL:** like Linux; needs `systemd=true` in `/etc/wsl.conf`.

Check: `ls /cellar/$USER` should show `Documents Downloads`.

## 3. Move existing data, then link

`link.sh` refuses to replace a non-empty directory, so copy first, verify, then move the
old one aside. `~/Documents` is large (about 39G), so run it from a wired connection:

```sh
rsync -aPh --no-perms --no-owner --no-group ~/Documents/ /cellar/$USER/Documents/
rsync -aniv --no-perms --no-owner --no-group ~/Documents/ /cellar/$USER/Documents/   # should list nothing
mv ~/Documents ~/Documents.local-old
tools/nfs/link.sh
```

Same for Downloads. Delete `*.local-old` only after you have used the new location for a
while. The sops key is in `~/Documents/secrets`, so test decryption right after.

## Caching and offline

Linux gets a local read cache from FS-Cache (`fsc`, needs `cachefilesd`). macOS has no
disk cache for NFS. On both, a share that is unreachable means the files are unavailable,
and the symlinks dangle until `/cellar/<user>` is mounted again.

## Media (deferred): plan

Today `tank/media` is one dataset holding `adult books downloads movies music tv`, owned
by uid 3002 / gid 3000, because it was easy to attach to kube pods as one PVC.
Questions to settle before touching it:

- Split into child datasets (`media/movies`, `media/music`, ...) so snapshots, quotas and
  recordsize can differ per type. Mounted under the old path they would keep
  `/mnt/tank/media/movies`, so existing NFS PVCs and the torrent client need no changes,
  but each existing directory must be recreated as a dataset and its data moved in.
- Keep `downloads` as its own dataset, since it is the high-churn one.
- Decide who writes: the kube services (uid 3002) or people. Easiest is read-only NFS
  exports to desktops plus group `media` (gid 3000) for anyone who needs to write.
- Then mount at `/cellar/media`, link as `~/Media`, and leave `~/Music` and `~/Movies`
  local (they hold DAW libraries and recordings).
