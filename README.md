# dotfiles

Dotfiles for macOS, Linux (Fedora, Debian, Arch) and WSL, managed with
[chezmoi](https://www.chezmoi.io/). This repo is public: it holds no secrets, and
anything personal, machine- or employer-specific lives in a separate private repo.

The commands below use `scbunn/dotfiles`. To use these dotfiles yourself, fork the
repo and replace that with your own fork.

## Set up a new machine

1. Install the tools in [docs/install.md](docs/install.md) (at least `git` and `chezmoi`),
   plus the Nerd Font.
2. Clone and apply over HTTPS, so no SSH key is needed yet:

   ```sh
   chezmoi init --apply https://github.com/scbunn/dotfiles.git
   ```

   This clones to `~/.local/share/chezmoi` and writes the dotfiles into `$HOME`.
   To check first, run `chezmoi init https://github.com/scbunn/dotfiles.git`,
   then `chezmoi diff`, and apply with `chezmoi apply`.
3. Add your private repo (see [The private repo](#the-private-repo)). Without it git
   has no identity and no extra shell config is loaded:

   ```sh
   git clone <your-private-repo-url> ~/.local/share/dotfiles-private
   ```

4. Open a new terminal. The first run clones the zsh plugins, so it needs network.
5. Restore or create GPG keys for commit signing and SSH: [docs/gnupg.md](docs/gnupg.md).
6. Optional extras:
   - Build the tmux now-playing tool from the source directory (`chezmoi cd`):
     `go build -o ~/.local/bin/nowplaying ./tools/nowplaying`. It needs `LASTFM_USER`
     and `LASTFM_API_KEY`; put the key in `~/.envrc` and run `direnv allow ~`.
   - For more than one GitHub account, log in to each with its own config directory:
     `GH_CONFIG_DIR=~/.config/gh-<account> gh auth login`.
   - Linux desktop only: install the files under `system/` by hand (see the comment at
     the top of each file).
   - Linux desktop only: re-select the avatar once in Noctalia's Control Center. Only
     the picker hands it to AccountsService, where the login greeter reads it;
     `avatar_path` in the config alone doesn't.

## The private repo

The public config reads two things from `~/.local/share/dotfiles-private`:

| Path | Read by | Holds |
|------|---------|-------|
| `gitconfig` | `~/.config/git/config` (`[include]`) | `[user]` name, email, signing key; `includeIf` rules; URL rewrites |
| `zsh/*.zsh` | end of `.zshrc` | per-machine environment variables, aliases, functions |

A minimal one:

```
dotfiles-private/
├── gitconfig
└── zsh/
    └── local.zsh
```

```ini
# gitconfig
[user]
	name = Your Name
	email = you@example.com
	signingkey = <SIGNING_SUBKEY_ID>

# a different identity for one folder (path is relative to this file)
[includeIf "gitdir:~/source/other-project/"]
	path = other-project.gitconfig
```

Use a separate private repo for each context (for example home and work), and never
commit keys or tokens to it. See [docs/git.md](docs/git.md) for more about the git setup.

## Values to change for your own use

These are tracked in this repo and name the original owner:

| File | Value |
|------|-------|
| `dot_config/zsh/dot_zshenv` | `LASTFM_USER` |
| `system/polkit-1/rules.d/50-noctalia-greeter-sync.rules` | the user allowed to sync the greeter |

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

If the repo is cloned elsewhere (for example `~/source/dotfiles`), point chezmoi at it
once; `.chezmoi.toml.tmpl` then keeps `sourceDir` in `~/.config/chezmoi/chezmoi.toml`:

```sh
chezmoi init --source ~/source/dotfiles
```

The private repo path is fixed, so for a checkout elsewhere symlink it into place:

```sh
ln -sn ~/source/dotfiles-private ~/.local/share/dotfiles-private
```

## Layout

| Path | Purpose |
|------|---------|
| `dot_config/` | files for `~/.config` (zsh, nvim, tmux, git, starship, eza, kitty, hypr, noctalia) |
| `.chezmoitemplates/` | not installed; per-machine Hyprland monitor profiles |
| `dot_zshenv` | sets `ZDOTDIR` so zsh reads `~/.config/zsh` |
| `private_dot_gnupg/` | gpg-agent config (a template: picks the pinentry per OS) |
| `system/` | not installed by chezmoi; system files (polkit rule, NVIDIA modprobe options) installed by hand with sudo |
| `tools/` | not installed by chezmoi; `nowplaying` (Go) for the tmux status bar |
| `docs/` | install requirements, GPG, git |
| `themes/` | not installed by chezmoi; terminal themes imported by hand (iTerm2) |

### Linux-only configs

Linux desktop configs (kitty, Hyprland, Noctalia) are skipped on macOS and WSL.
The list lives in the `$linuxDesktop` block at the end of `.chezmoiignore`;
add each new Linux-only path there.

### Monitor profiles

`~/.config/hypr/config/monitors.lua` is built from one of
`.chezmoitemplates/hypr/monitors/<profile>.lua`: `desktop` (Alienware AW3423DW),
`laptop` (built-in panel) or `auto` (every output at its preferred mode). `chezmoi init`
asks for the profile once on a Linux desktop and stores it as `monitor_profile` in
`~/.config/chezmoi/chezmoi.toml`. To switch, change that value and run `chezmoi apply`.
For a new machine, add a profile file and add its name to the list in `.chezmoi.toml.tmpl`.

The NVIDIA lines in `environment.lua` are added only when `nvidia-smi` is installed.

### Noctalia

Noctalia reads two files. `~/.config/noctalia/config.toml` is tracked and holds every
setting. `~/.local/state/noctalia/settings.toml` is written by the Noctalia settings app,
overrides `config.toml`, and is not tracked: it also stores the current wallpaper, which
changes every hour.

After changing something in the settings app, copy the new keys from `settings.toml`
into `dot_config/noctalia/config.toml`, then delete them from `settings.toml` so it
keeps only `config_version`, `[lockscreen_widgets]` and `[wallpaper.*]` paths.

Wallpapers rotate hourly from `~/Pictures/wallpaper/` (not tracked; copy images there).
