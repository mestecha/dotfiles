#!/usr/bin/env zsh
#
# zshrc
#
# minimal zsh config 
# sources bashrc for shared config
#

# exit early if not interactive
[[ -o interactive ]] || return

# source bashrc for shared config (aliases, functions, environment)
# bash-specific sections are guarded with [[ -n $BASH_VERSION ]]
[[ -f ~/.bashrc ]] && . ~/.bashrc

# path (bashrc uses bics path_add which is bash-only)
path=(~/bin ~/.local/bin ~/.cargo/bin $path)
typeset -U path  # remove duplicates

# zsh-specific shell options
setopt autocd              # cd by typing directory name
setopt extendedglob        # extended pattern matching
setopt nomatch             # error if glob has no matches
setopt notify              # report job status immediately
setopt promptsubst         # allow command substitution in prompt
setopt interactivecomments # allow comments in interactive shell
setopt histignoredups      # no duplicate history entries
setopt histignorespace     # ignore commands starting with space
setopt sharehistory        # share history between sessions

# history settings
HISTFILE=~/.zsh_history
HISTSIZE=5000
SAVEHIST=5000

# prompt colors using zsh native escapes (faster than tput, no parsing issues)
# %F{N} = foreground color N, %f = reset fg, %B = bold, %b = end bold
_c_reset='%f%b'
_c_bold='%B'
_c_red='%F{1}'

# generate prompt colors from 256 palette (matching bashrc algorithm)
# uses colors where i % 30 == 24, starting from 22
# zsh arrays are 1-indexed, so start at 1
_prompt_colors=()
_j=1
for _i in {22..231}; do
	((_i % 30 == 24)) || continue
	_prompt_colors[$_j]="%F{$_i}"
	((_j++))
done
unset _i _j

# git branch for prompt
_git_branch() {
	local branch
	branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null) || return
	echo "($_prompt_colors[4]git:$branch$_prompt_colors[3]) "
}

# build prompt
# format: (exit code) user - hostname os working/dir (git:branch) $
# uses zsh prompt escapes: %n=user, %m=hostname, %~=path, %#=$/# for user/root
# zsh arrays are 1-indexed: [1]=color0, [4]=color3, [3]=color2, [6]=color5

PROMPT=''

# exit code if non-zero (%) escapes literal ) inside conditional)
PROMPT+='%(?..%F{1}(%?%)%f )'

# username (red if root)
PROMPT+='$_prompt_colors[1]$_c_bold%(!.$_c_red.)%n$_c_reset - '

# hostname
PROMPT+='$_prompt_colors[4]%m '

# uname
PROMPT+='$_prompt_colors[3]'"$(uname | tr '[:upper:]' '[:lower:]')"' '

# working directory
PROMPT+='$_prompt_colors[6]%~ '

# git branch
PROMPT+='$(_git_branch)'

# $ or # prompt character
PROMPT+='$_prompt_colors[1]%#$_c_reset '

# terminal title: [ssh] user@host:path
_set_title() {
	local ssh=
	[[ -n $SSH_CLIENT ]] && ssh='[ssh] '
	print -Pn "\033]0;${ssh}%n@%m:%~\007"
}

# run before each prompt
precmd_functions+=(_set_title)

# completion
autoload -Uz compinit
compinit -d ~/.zcompdump

# case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
# menu selection
zstyle ':completion:*' menu select
# colors in completion
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# edit command line in $EDITOR
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line

# emacs keybindings
bindkey -e

# local overrides (not tracked in git)
[[ -f ~/.zshrc.local ]] && . ~/.zshrc.local

true
