# dotfiles

personal dotfiles for bash/zsh on linux and macos.

based on [bahamas10's dotfiles](https://github.com/bahamas10/dotfiles).

## install

```bash
git clone https://github.com/mestecha/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install      # without gitconfig
./install -f   # with gitconfig (includes identity)
```

## requirements

- neovim 0.11+
- gcc (treesitter parsers)
- curl, tar
- nerd font (icons)
- clang-format (optional, for c++ formatting)

```bash
# macos
brew install neovim gcc

# ubuntu/wsl
sudo add-apt-repository -y ppa:neovim-ppa/unstable
sudo apt update && sudo apt install -y neovim build-essential
```

## structure

```
bashrc          # shared shell config (aliases, functions, env)
bash_profile    # sources bashrc
zshrc           # zsh config (sources bashrc, adds zsh-specifics)
vimrc           # vim config
vim/            # vim plugins (vim-plug)
tmux.conf       # tmux config
inputrc         # readline config
gitconfig       # git config (use -f to install)
bics-plugins/   # bash plugins (submodules)
```

## neovim

nvim config is in a separate repo: [mestecha/nvim](https://github.com/mestecha/nvim)

```bash
git clone https://github.com/mestecha/nvim.git ~/nvim
cd ~/nvim && ./install
```

## local overrides

machine-specific config (not tracked):

```
~/.bashrc.local      # bash-specific local config
~/.zshrc.local       # zsh-specific local config (homebrew, nvm, etc)
~/.bash_aliases      # local aliases
~/.gitconfig.local   # local git config
```

## plugins

**bash** - [bics](https://github.com/bahamas10/bics) for path management

**vim** - [vim-plug](https://github.com/junegunn/vim-plug), run `:PlugInstall`
