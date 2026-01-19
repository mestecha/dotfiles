# dotfiles

personal dotfiles for bash on linux (wsl) and macos.

based on [bahamas10's dotfiles](https://github.com/bahamas10/dotfiles).

## requirements

- neovim 0.10+ (for nvim-treesitter)
- gcc (for compiling treesitter parsers)
- curl, tar (for downloads)

```bash
# ubuntu/wsl - install neovim from ppa
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update && sudo apt install -y neovim
```

## install

```bash
git clone https://github.com/mestecha/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install      # without gitconfig
./install -f   # with gitconfig (includes my identity)
```

the install script will:
- symlink all dotfiles to home
- install bics (bash plugin manager)
- install tree-sitter-cli (for nvim-treesitter)
- install vim plugins (vim-plug)
- install nvim plugins and treesitter parsers (lazy.nvim)
- set macos defaults (if on macos)
- symlink .aws/.azure from windows (if on wsl)

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
~/.bashrc.local      # local bash config (cuda, etc)
~/.bash_aliases      # local aliases
~/.gitconfig.local   # local git config (signing, etc)
```

## plugins

**bash** - uses [bics](https://github.com/bahamas10/bics):
- `bash-path` - path_add, path_remove, path_clean

**vim** - uses [vim-plug](https://github.com/junegunn/vim-plug):
- run `:PlugInstall` to install

**nvim** - uses [lazy.nvim](https://github.com/folke/lazy.nvim):
- plugins auto-install on first launch
- run `:Lazy sync` to update
