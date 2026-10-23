# GPG Setup (macOS and Linux)

Based on: https://alexnorell.com/post/set-up-gpg/

Sets up GPG for two purposes:
- **Git commit and tag signing**
- **SSH authentication** (replaces ssh-agent)

Private keys are stored in 1Password:
- `master-secret-key.gpg` — primary/master key
- `sub-secret-keys.gpg` — signing and authentication subkeys

---

## Installation

```bash
brew install gnupg pinentry-mac
```

---

## Restoring on a New Machine

This is the common case — keys already exist in 1Password.

### 1. Configure pinentry-mac

```bash
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
echo "use-standard-socket" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

### 2. Import keys from 1Password

Export both files from 1Password, then:

```bash
gpg --import master-secret-key.gpg
gpg --import sub-secret-keys.gpg
```

Set ultimate trust on the primary key:

```bash
gpg --list-secret-keys   # get your key fingerprint
gpg --edit-key <FINGERPRINT>
# at the gpg> prompt:
trust
# choose 5 (ultimate)
quit
```

### 3. Register the authentication subkey for SSH

Find the keygrip of the `[A]` subkey:

```bash
gpg --list-secret-keys --with-keygrip
```

Add it to sshcontrol:

```bash
echo "<KEYGRIP_OF_AUTH_SUBKEY>" >> ~/.gnupg/sshcontrol
```

### 4. Configure shell (zsh)

Add to `~/.zshrc` (or `~/.config/extras.zsh`):

```zsh
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
```

Reload your shell, then verify SSH key is available:

```bash
ssh-add -L
# should print: ssh-ed25519 AAAA...
```

### 5. Configure git

```bash
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global user.signingkey <SIGNING_SUBKEY_FINGERPRINT>
```

The signing key is the last 16 hex chars of your `[S]` subkey fingerprint, or set the full fingerprint.

### 6. Shred the exported key files

```bash
shred -uzv master-secret-key.gpg sub-secret-keys.gpg
```

---

## Restoring on Linux (Arch / CachyOS)

Same keys, same steps as macOS. Only the differences are listed here.

### Packages

```bash
sudo pacman -S --needed gnupg pinentry pcsclite
```

`pinentry` provides `pinentry-qt`, `pinentry-gnome3`, `-curses` and `-tty`.

### Agent config and shell

chezmoi handles both. Nothing to append by hand:

- `gpg-agent.conf` (template) sets `pinentry-program /usr/bin/pinentry-qt`.
  Do not use the `/usr/bin/pinentry` wrapper. On Hyprland it picks
  `pinentry-gnome3`, which needs GNOME services to show a prompt.
- `.zshenv` sets `SSH_AUTH_SOCK` from `gpgconf --list-dirs agent-ssh-socket`.
  systemd starts gpg-agent from a socket unit, so the sockets are in
  `/run/user/$UID/gnupg/`, not in `~/.gnupg/` as on macOS.

Make sure the OpenSSH agent is not running, or it will own `SSH_AUTH_SOCK`:

```bash
systemctl --user is-active ssh-agent.service   # should be inactive
```

### Exported key files: keep them off NFS

`~/Downloads` may be a symlink to the NFS share on cellar. `shred` does not
work on NFS or ZFS: ZFS writes changes to new blocks, and snapshots keep old
copies. Move the exports to tmpfs before importing:

```bash
D=$(mktemp -d /run/user/$UID/gpgimport.XXXX)
mv ~/Downloads/master-secret-key.gpg ~/Downloads/sub-secret-keys.gpg "$D"/
gpg --batch --import "$D"/*.gpg
rm -rf "$D"
```

Trust and sshcontrol can be done without the interactive prompts:

```bash
echo "<PRIMARY_FINGERPRINT>:6:" | gpg --import-ownertrust
echo "<KEYGRIP_OF_AUTH_SUBKEY>" >> ~/.gnupg/sshcontrol
ssh-add -L
```

---

## Fresh Setup (New Keys)

Only do this if you don't have existing keys in 1Password.

### 1. Install and configure pinentry-mac

```bash
brew install gnupg pinentry-mac
echo "pinentry-program $(which pinentry-mac)" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

### 2. Generate primary key

```bash
gpg --full-generate-key
```

Selections:
- Type: `(9) ECC (sign and encrypt)`
- Curve: `(1) Curve 25519`
- Expiration: `1y`
- Use a strong passphrase — store it in 1Password

Export and store the fingerprint:

```bash
export PRIMARY="<40_CHAR_FINGERPRINT>"
```

### 3. Create subkeys

Authentication subkey (for SSH):

```bash
gpg --quick-add-key $PRIMARY ed25519 auth 1y
```

Signing subkey (for git):

```bash
gpg --quick-add-key $PRIMARY ed25519 sign 1y
```

### 4. Configure gpg-agent

```bash
echo "enable-ssh-support" >> ~/.gnupg/gpg-agent.conf
echo "use-standard-socket" >> ~/.gnupg/gpg-agent.conf
gpg-connect-agent reloadagent /bye
```

### 5. Register auth subkey for SSH

```bash
gpg --list-secret-keys --with-keygrip $PRIMARY | \
  sed -n '/\[A\]/,/Keygrip/p' | \
  awk '/Keygrip/ {print $3}' \
  >> ~/.gnupg/sshcontrol
```

### 6. Configure shell (zsh)

```zsh
export GPG_TTY="$(tty)"
export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
gpgconf --launch gpg-agent
```

### 7. Configure git

```bash
export SIGNING_KEY=$(
  gpg --list-keys --with-subkey-fingerprints $PRIMARY | \
  sed -n '/\[S\]/,+1p' | \
  awk '/^[[:space:]]+[0-9A-F]{40}/ {print $1}'
)
git config --global commit.gpgsign true
git config --global tag.gpgSign true
git config --global user.signingkey $SIGNING_KEY
```

### 8. Publish keys to GitHub

SSH key:

```bash
ssh-add -L
# paste output at https://github.com/settings/ssh/new
```

GPG key:

```bash
gpg --export --armor $PRIMARY
# paste output at https://github.com/settings/gpg/new
```

### 9. Back up and harden

Export keys for 1Password:

```bash
# Primary/master key
gpg --export-secret-keys --armor $PRIMARY > master-secret-key.gpg

# Subkeys only
gpg --export-secret-subkeys --armor $PRIMARY > sub-secret-keys.gpg
```

Store both files in 1Password, then delete the primary private key from the local keyring:

```bash
gpg --delete-secret-keys $PRIMARY\!
shred -uzv master-secret-key.gpg sub-secret-keys.gpg
```

---

## Reference

| File | Purpose |
|------|---------|
| `~/.gnupg/gpg-agent.conf` | Agent config: pinentry-mac, SSH support |
| `~/.gnupg/gpg.conf` | GPG options |
| `~/.gnupg/sshcontrol` | Keygrips of GPG subkeys exposed as SSH keys |
| `1Password: master-secret-key.gpg` | Primary key backup |
| `1Password: sub-secret-keys.gpg` | Subkey backup |

Key fingerprints for this machine — find with:

```bash
gpg --list-secret-keys --with-keygrip --with-subkey-fingerprints
```
