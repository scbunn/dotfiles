# Git configuration

chezmoi writes the shared config to `~/.config/git/config`: aliases, colors, pager,
merge and pull rules, and GPG signing for every commit and tag. There is no
`~/.gitconfig`; if one exists, git reads both, so remove it to avoid surprises.

The shared config has no identity. It includes `~/.local/share/dotfiles-private/gitconfig`
from the private repo (see the README), which holds everything specific to the
person or machine:

```ini
[user]
	name = Your Name
	email = you@example.com
	signingkey = <SIGNING_SUBKEY_ID>

# a different identity for repos under one folder (path is relative to this file)
[includeIf "gitdir:~/source/other-project/"]
	path = other-project.gitconfig

# clone over SSH even when given an HTTPS URL
[url "ssh://git@gitlab.example.com/"]
	insteadOf = https://gitlab.example.com/
```

Put changes there, not in `git config --global`: that writes to `~/.config/git/config`,
which is managed by chezmoi, so the next `chezmoi apply` would undo it.

## Tools the config expects

`git-lfs`, `diff-so-fancy` (pager) and `fzf` (the interactive aliases such as
`git addm` and `git cb`). See [install.md](install.md).

Check where each setting comes from:

```sh
git config --list --show-origin
```
