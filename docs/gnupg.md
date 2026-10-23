# GPG setup (macOS, Linux, WSL)

Based on: https://alexnorell.com/post/set-up-gpg/

GPG is used for two things:
- **Git commit and tag signing**
- **SSH authentication** (gpg-agent replaces ssh-agent)

The keys are one primary key plus a signing subkey and an authentication subkey. Keep
an offline backup of both exports (for example in a password manager):
- `master-secret-key.gpg`: primary key
- `sub-secret-keys.gpg`: signing and authentication subkeys

## What chezmoi sets up

Nothing here needs to be added by hand:

- `~/.gnupg/gpg-agent.conf` (a template) turns on SSH support and picks the pinentry:
  `pinentry-mac` on macOS, `pinentry-qt` on Linux (falls back to `pinentry-tty`), and
  the Windows GnuPG `pinentry-basic.exe` on WSL when it is installed. On Linux, do not
  use the `/usr/bin/pinentry` wrapper: under Hyprland it picks `pinentry-gnome3`, which
  needs GNOME services to show a prompt.
- `.zshenv` sets `GPG_TTY` and points `SSH_AUTH_SOCK` at the agent with
  `gpgconf --list-dirs agent-ssh-socket`. That is `~/.gnupg/` on macOS and
  `/run/user/$UID/gnupg/` on systemd Linux, where a socket unit starts gpg-agent.

## Packages

| OS | Install |
|----|---------|
| macOS | `brew install gnupg pinentry-mac` |
| Arch | `sudo pacman -S --needed gnupg pinentry pcsclite` |
| Fedora | `sudo dnf install gnupg2 pinentry` |
| Debian / WSL | `sudo apt install gnupg pinentry-tty` |

On Linux make sure the OpenSSH agent is not running, or it will own `SSH_AUTH_SOCK`:

```bash
systemctl --user is-active ssh-agent.service   # should be inactive
```

## Restore keys on a new machine

The common case: the keys already exist in your backup.

### 1. Put the exports somewhere safe

`shred` only works on local, non-copy-on-write disks. If `~/Downloads` is on a network
share, ZFS or btrfs, old copies can survive. Import from tmpfs instead:

```bash
D=$(mktemp -d /run/user/$UID/gpgimport.XXXX)   # macOS: D=$(mktemp -d)
mv ~/Downloads/master-secret-key.gpg ~/Downloads/sub-secret-keys.gpg "$D"/
```

### 2. Import and trust

```bash
gpg --batch --import "$D"/*.gpg
gpg --list-secret-keys --with-keygrip --with-subkey-fingerprints
echo "<PRIMARY_FINGERPRINT>:6:" | gpg --import-ownertrust   # 6 = ultimate
```

### 3. Expose the authentication subkey to SSH

Add the keygrip of the `[A]` subkey from the listing above:

```bash
echo "<KEYGRIP_OF_AUTH_SUBKEY>" >> ~/.gnupg/sshcontrol
ssh-add -L   # should print an ssh-ed25519 key
```

### 4. Configure git

Set `signingkey` in the private repo's `gitconfig` (see [git.md](git.md)), not with
`git config --global`. Use the last 16 hex characters of the `[S]` subkey fingerprint,
or the full fingerprint. Signing is already turned on in the shared config.

### 5. Remove the exports

```bash
shred -uz "$D"/*.gpg 2>/dev/null; rm -rf "$D"
```

## Fresh setup (new keys)

Only if you do not have keys yet.

### 1. Generate the primary key

```bash
gpg --full-generate-key
```

Selections:
- Type: `(9) ECC (sign and encrypt)`
- Curve: `(1) Curve 25519`
- Expiration: `1y`
- A strong passphrase, kept in your password manager

```bash
export PRIMARY="<40_CHAR_FINGERPRINT>"
```

### 2. Create the subkeys

```bash
gpg --quick-add-key $PRIMARY ed25519 auth 1y   # SSH
gpg --quick-add-key $PRIMARY ed25519 sign 1y   # git
```

### 3. Register the auth subkey for SSH

```bash
gpg --list-secret-keys --with-keygrip $PRIMARY | \
  sed -n '/\[A\]/,/Keygrip/p' | \
  awk '/Keygrip/ {print $3}' \
  >> ~/.gnupg/sshcontrol
```

### 4. Find the signing key for git

```bash
gpg --list-keys --with-subkey-fingerprints $PRIMARY | \
  sed -n '/\[S\]/,+1p' | \
  awk '/^[[:space:]]+[0-9A-F]{40}/ {print $1}'
```

Put it in the private repo's `gitconfig` as `user.signingkey`.

### 5. Publish the public keys to GitHub

```bash
ssh-add -L                    # paste at https://github.com/settings/ssh/new
gpg --export --armor $PRIMARY # paste at https://github.com/settings/gpg/new
```

### 6. Back up and harden

```bash
gpg --export-secret-keys --armor $PRIMARY > master-secret-key.gpg
gpg --export-secret-subkeys --armor $PRIMARY > sub-secret-keys.gpg
```

Store both files in your backup, then delete the primary secret key from the local
keyring (the subkeys stay) and remove the exports:

```bash
gpg --delete-secret-keys $PRIMARY\!
shred -uz master-secret-key.gpg sub-secret-keys.gpg
```

## Reference

| File | Purpose |
|------|---------|
| `~/.gnupg/gpg-agent.conf` | agent config (managed by chezmoi): pinentry, SSH support |
| `~/.gnupg/sshcontrol` | keygrips of subkeys exposed as SSH keys |
| `master-secret-key.gpg` (backup) | primary key |
| `sub-secret-keys.gpg` (backup) | subkeys |
