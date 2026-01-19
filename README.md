# dotfiles

personal dotfiles for bash on linux (wsl) and macos.

based on [bahamas10's dotfiles](https://github.com/bahamas10/dotfiles).

## install

```
git clone https://github.com/mestecha/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install      # without gitconfig
./install -f   # with gitconfig (includes my identity)
```

## structure

```
bashrc          # main shell config
bash_profile    # sources bashrc
vimrc           # vim config
vim/            # vim plugins (vim-plug)
nvim/           # neovim config (lua, lazy.nvim)
tmux.conf       # tmux config
inputrc         # readline config
gitconfig       # git config (use -f to install)
bics-plugins/   # bash plugins (submodules)
```

## local overrides

create these files for machine-specific config (not tracked):

```
~/.bashrc.local      # local bash config
~/.bash_aliases      # local aliases
~/.gitconfig.local   # local git config (signing, etc)
```

## plugins

uses [bics](https://github.com/bahamas10/bics) for bash plugins:

- `bash-path` - path_add, path_remove, path_clean
