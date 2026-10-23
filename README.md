# dotfiles

Personal dotfiles for macOS, Linux (Fedora, Debian, Arch) and WSL, managed with
[chezmoi](https://www.chezmoi.io/). This repo is public: it holds no secrets, and
anything machine- or employer-specific lives in a separate private repo.

## Set up a new machine

1. Install the tools in [docs/install.md](docs/install.md) (at least `git` and `chezmoi`),
   plus the Nerd Font.
2. Clone and apply over HTTPS, so no SSH key is needed yet:

   ```sh
   chezmoi init --apply https://github.com/scbunn/dotfiles.git
   ```

   This clones to `~/.local/share/chezmoi` and writes the dotfiles into `$HOME`.
   Check first with `chezmoi init https://github.com/scbunn/dotfiles.git`
   then `chezmoi diff`, and apply with `chezmoi apply`.
3. Add the private repo, which holds the git identity and per-machine shell config
   (`gitconfig`, `zsh/*.zsh`). Without it git has no identity and nothing extra is sourced:

   ```sh
   git clone <your-private-repo-url> ~/.local/share/dotfiles-private
   ```

   Use a separate private repo for work and for home.
4. Open a new terminal. The first run clones the zsh plugins, so it needs network.
5. Build the status-bar tool: `go build -o ~/.local/bin/nowplaying ./tools/nowplaying`
   from the chezmoi source directory (`chezmoi source-path`).
6. Restore GPG keys for signing: [docs/gnupg.md](docs/gnupg.md).

## Day to day

```sh
chezmoi diff             # what apply would change
chezmoi apply            # write the repo to $HOME
chezmoi re-add           # pull edits made to live files back into the repo
chezmoi cd               # shell in the source directory
```

Commit and push from the source directory. Switch the remote to SSH on machines
where you push: `git remote set-url origin git@github.com:scbunn/dotfiles.git`.

## Using a checkout somewhere other than the default

If the repo is cloned elsewhere (for example `~/source/dotfiles`), tell chezmoi in
`~/.config/chezmoi/chezmoi.toml`:

```toml
sourceDir = "~/source/dotfiles"
```

The private repo path is fixed, so for a checkout elsewhere symlink it into place:

```sh
ln -sn ~/source/dotfiles-private ~/.local/share/dotfiles-private
```

## Layout

| Path | Purpose |
|------|---------|
| `dot_config/` | files for `~/.config` (zsh, nvim, tmux, git, starship, eza, kitty, hypr) |
| `dot_zshenv` | sets `ZDOTDIR` so zsh reads `~/.config/zsh` |
| `private_dot_gnupg/` | gpg-agent config (a template: picks the pinentry per OS) |
| `tools/` | not installed by chezmoi; `nowplaying` (Go) and `nfs` scripts |
| `docs/` | install requirements, GPG, git, NFS |
| `themes/` | not installed by chezmoi; terminal themes imported by hand (iTerm2) |

### Linux-only configs

Linux desktop configs (kitty, Hyprland) are skipped on macOS and WSL.
The list lives in the `$linuxDesktop` block at the end of `.chezmoiignore`;
add each new Linux-only path there.

### Noctalia

Noctalia reads two files. `~/.config/noctalia/config.toml` is tracked and holds every
setting. `~/.local/state/noctalia/settings.toml` is written by the Noctalia settings app,
overrides `config.toml`, and is not tracked: it also stores the current wallpaper, which
changes every hour.

After changing something in the settings app, copy the new keys from `settings.toml`
into `dot_config/noctalia/config.toml`, then delete them from `settings.toml` so it
keeps only `config_version`, `[lockscreen_widgets]` and `[wallpaper.*]` paths.

Wallpapers rotate hourly from `~/Pictures/wallpaper/` (not tracked; copy images there).
