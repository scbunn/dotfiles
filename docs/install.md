# Install requirements

What a new machine needs before `chezmoi apply` gives a working setup. The OS
install scripts (to be written) should be built from this list.

## Supported platforms

- macOS (Sequoia and latest), Homebrew
- Fedora (dnf)
- Debian (apt)
- Arch (pacman)
- WSL, Debian (apt); see WSL notes

**Package names below are NOT yet verified** on Fedora, Debian, Arch or WSL. Only the
brew column has been checked. `?` means it may not be packaged; fall back to the
upstream installer.

## Core (required)

| Tool | Why | brew | dnf | apt | pacman |
|------|-----|------|-----|-----|--------|
| git | everything | `git` | `git` | `git` | `git` |
| git-lfs | git config filter | `git-lfs` | `git-lfs` | `git-lfs` | `git-lfs` |
| diff-so-fancy | git pager | `diff-so-fancy` | `diff-so-fancy` ? | `diff-so-fancy` | `diff-so-fancy` |
| zsh | shell | `zsh` | `zsh` | `zsh` | `zsh` |
| tmux (>= 3.2) | multiplexer | `tmux` | `tmux` | `tmux` (check version) | `tmux` |
| neovim (>= 0.10) | editor (LazyVim) | `neovim` | `neovim` | `neovim` (often too old; use release tarball) | `neovim` |
| chezmoi | applies these dotfiles | `chezmoi` | `get.chezmoi.io` ? | `get.chezmoi.io` ? | `chezmoi` |
| starship | prompt | `starship` | starship.rs script ? | `starship` ? | `starship` |
| fzf (>= 0.48 for `--zsh`) | fuzzy finder | `fzf` | `fzf` | `fzf` (often too old; use release) | `fzf` |
| zoxide | smarter `cd` | `zoxide` | `zoxide` | `zoxide` | `zoxide` |
| direnv | per-folder env (`.envrc`) | `direnv` | `direnv` | `direnv` | `direnv` |

## Shell quality of life (optional, aliases fall back if missing)

| Tool | Why | brew | dnf | apt | pacman |
|------|-----|------|-----|-----|--------|
| eza | `ls`, `ll`, `la`, `tree` | `eza` | `eza` | `eza` ? | `eza` |
| bat | `cat` alias | `bat` | `bat` | `bat` (binary `batcat`) | `bat` |
| fd | fzf file search | `fd` | `fd-find` | `fd-find` (binary `fdfind`) | `fd` |
| ripgrep | search | `ripgrep` | `ripgrep` | `ripgrep` | `ripgrep` |
| jq | JSON | `jq` | `jq` | `jq` | `jq` |

## Font

- **JetBrainsMono Nerd Font**: icons in eza, starship and nvim.
  - macOS: `brew install --cask font-jetbrains-mono-nerd-font`
  - Linux: download from the nerd-fonts releases into `~/.local/share/fonts`, then `fc-cache -fv`
  - WSL: install on the **Windows** side; WSL uses the Windows terminal's font.
  - Then set it as the terminal font (iTerm2: Settings > Profiles > Text).

## Secrets and signing

| Tool | Why | brew | dnf | apt | pacman |
|------|-----|------|-----|-----|--------|
| gnupg | commit signing | `gnupg` | `gnupg2` | `gnupg` | `gnupg` |
| pinentry | passphrase prompt | `pinentry-mac` | `pinentry` | `pinentry-curses` / `pinentry-tty` | `pinentry` |
| sops | encrypted secrets | `sops` | release binary ? | release binary ? | `sops` |
| age | key for sops | `age` | `age` | `age` | `age` |
| gh | GitHub CLI | `gh` | `gh` | `gh` | `github-cli` |

If you use SOPS, `.zshenv` sets `SOPS_AGE_KEY_FILE` to the default age key location,
`$XDG_CONFIG_HOME/sops/age/keys.txt` (`~/.config/sops/age/keys.txt`). Put your key
there or override the variable.

## Development

| Tool | Why | brew | dnf | apt | pacman |
|------|-----|------|-----|-----|--------|
| go | builds `tools/nowplaying` | `go` | `golang` | `golang` (may be old) | `go` |
| kubectl, flux | completions loaded if present | `kubectl`, `fluxcd/tap/flux` | upstream | upstream | `kubectl`, `fluxcd` ? |

## Platform notes

- **macOS:** Homebrew is a user-local install at `~/.homebrew` (no sudo). The zsh config
  detects it; it does not assume `/opt/homebrew`.
- **Debian / WSL:** `bat` and `fd` install as `batcat` / `fdfind`; symlink them into
  `~/.local/bin` as `bat` / `fd`.
- **Clipboard in tmux** uses OSC 52. The terminal must allow it (iTerm2: Settings >
  General > Selection > "Applications in terminal may access clipboard").
- **WSL:**
  - Debian under WSL2. Enable systemd in `/etc/wsl.conf` (`[boot] systemd=true`) if needed.
  - Fonts and the terminal font are configured in Windows Terminal, not in WSL.
  - OSC 52 clipboard works in Windows Terminal; otherwise `clip.exe` is the fallback.
  - GPG: use `pinentry-tty` (no GUI pinentry inside WSL).

## After install

See the steps in the [README](../README.md#set-up-a-new-machine).
