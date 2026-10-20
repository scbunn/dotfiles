# Git Configuration

```
brew install fzf git git-lfs diff-so-fancy

ln -sn config ~/.gitconfig

touch ~/.config/git.userinfo
touch ~/.config/git.rewrites
```

configure `~/.config/git.userinfo` with this machines [user] information.
configure ~/.config/git.rewrites with any url rewriting necessary for this machine


```
# example url rewrite
[url "ssh://git@gitlab.com/"]
  insteadOf = https://www.gitlab.com
```
