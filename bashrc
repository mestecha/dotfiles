#!/usr/bin/env bash
#
# bashrc
#
# based on bahamas10's dotfiles
# https://github.com/bahamas10/dotfiles
#

# exit early if not interactive
[[ -n $PS1 ]] || return

# load bics plugin manager (bash-only, provides path_add/path_clean)
if [[ -n $BASH_VERSION ]]; then
	. ~/.bics/bics || echo '> failed to load bics' >&2
fi

# environment
export EDITOR='vim'
export VISUAL='vim'
export PAGER='less'

# cyan for grep matches
export GREP_COLOR='1;36'

# no duplicate history entries
export HISTCONTROL='ignoredups'
export HISTSIZE=5000
export HISTFILESIZE=5000

# macos ls colors
export LSCOLORS='ExGxbEaECxxEhEhBaDaCaD'

# less colors for man pages
# begin blinking
export LESS_TERMCAP_mb=$(tput bold; tput setaf 1)
# begin bold
export LESS_TERMCAP_md=$(tput bold; tput setaf 1)
# end mode
export LESS_TERMCAP_me=$(tput sgr0)
# end standout
export LESS_TERMCAP_se=$(tput sgr0)
# standout
export LESS_TERMCAP_so=$(tput bold; tput setaf 3; tput setab 4)
# end underline
export LESS_TERMCAP_ue=$(tput sgr0)
# underline
export LESS_TERMCAP_us=$(tput smul; tput bold; tput setaf 2)
# reverse
export LESS_TERMCAP_mr=$(tput rev)
# dim
export LESS_TERMCAP_mh=$(tput dim)
# subscript
export LESS_TERMCAP_ZN=$(tput ssubm)
# end subscript
export LESS_TERMCAP_ZV=$(tput rsubm)
# superscript
export LESS_TERMCAP_ZO=$(tput ssupm)
# end superscript
export LESS_TERMCAP_ZW=$(tput rsupm)

# path (path_add provided by bics, bash-only)
if [[ -n $BASH_VERSION ]]; then
	path_add ~/bin before
	path_add ~/.local/bin before
	path_add ~/.cargo/bin before
fi

# bash-specific shell options
if [[ -n $BASH_VERSION ]]; then
	# autocorrect typos in cd
	shopt -s cdspell
	# update LINES/COLUMNS after each command
	shopt -s checkwinsize
	# extended pattern matching
	shopt -s extglob

	# bash 4+ options
	# cd by typing directory name
	shopt -s autocd   2>/dev/null || true
	# autocorrect directory typos
	shopt -s dirspell 2>/dev/null || true
fi

# typo aliases
alias ..='echo "cd .."; cd ..'
alias chomd='chmod'
alias gerp='grep'
alias suod='sudo'

# ls aliases
alias l='ls'
alias ll='ls -lha'
alias la='ls -A'

# conditional aliases
grep --color=auto < /dev/null &>/dev/null &&
	alias grep='grep --color=auto'

# linux equivalent of macos open
xdg-open --version &>/dev/null &&
	alias open='xdg-open'

# ls with colors
if ls --color=auto &>/dev/null; then
	# gnu ls
	alias ls='ls -p --color=auto'
else
	# macos ls
	alias ls='ls -p -G'
fi

# git aliases
alias ga='git add . --all'
alias gb='git branch'
alias gc='git clone'
alias gci='git commit -a'
alias gco='git checkout'
# diff ignoring lock files
alias gd="git diff ':!*lock'"
# full diff
alias gdf='git diff'
alias gi='git init'
alias gl='git log'
alias gp='git push origin HEAD'
# repo root
alias gr='git rev-parse --show-toplevel'
alias gs='git status'
alias gt='git tag'
alias gu='git pull'

# tmux aliases
# attach or create
alias tm='tmux attach || tmux new-session'
# attach to named
alias tma='tmux attach -t'
# new named session
alias tmns='tmux new-session -s'
alias tml='tmux list-sessions'

# python
alias activate='source .venv/bin/activate'
alias py='python3'

# get main branch name (main or master)
gmb() {
	local main
	main=$(git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null)
	# strip origin/ prefix
	main=${main#origin/}
	[[ -n $main ]] || return 1
	echo "$main"
}

# diff current branch against main
gbd() {
	local mb
	mb=$(gmb) || return 1
	git diff "$mb..HEAD"
}

# checkout main and pull
gcm() {
	local mb
	mb=$(gmb) || return 1
	git checkout "$mb" && git pull
}

# merge main into current branch
gmm() {
	local mb
	mb=$(gmb) || return 1
	git merge "$mb"
}

# bash-specific prompt
if [[ -n $BASH_VERSION ]]; then
	# prompt colors using 256-color palette
	COLOR256=()
	# red for errors
	COLOR256[0]=$(tput setaf 1)
	# reset
	COLOR256[256]=$(tput sgr0)
	# bold
	COLOR256[257]=$(tput bold)

	PROMPT_COLORS=()

	# generate prompt color palette from 256 colors
	set_prompt_colors() {
		local h=${1:-0}
		local color=
		local i=0
		local j=0
		for i in {22..231}; do
			((i % 30 == h)) || continue

			color=${COLOR256[$i]}
			if [[ -z $color ]]; then
				COLOR256[$i]=$(tput setaf "$i")
				color=${COLOR256[$i]}
			fi
			PROMPT_COLORS[$j]=$color
			((j++))
		done
	}

	# build prompt
	# format: (exit code) user - hostname os working/dir (git:branch) $

	# exit code if non-zero
	PS1='$(ret=$?;(($ret!=0)) && echo "\[${COLOR256[0]}\]($ret) \[${COLOR256[256]}\]")'

	# username (red if root)
	PS1+='\[${PROMPT_COLORS[0]}\]\[${COLOR256[257]}\]$(((UID==0)) && echo "\[${COLOR256[0]}\]")\u\[${COLOR256[256]}\] - '

	# hostname
	PS1+='\[${PROMPT_COLORS[3]}\]\h '

	# uname
	PS1+='\[${PROMPT_COLORS[2]}\]'"$(uname | tr '[:upper:]' '[:lower:]')"' '

	# working directory
	PS1+='\[${PROMPT_COLORS[5]}\]\w '

	# git branch (optional)
	PS1+='$(branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); [[ -n $branch ]] && echo "\[${PROMPT_COLORS[2]}\](\[${PROMPT_COLORS[3]}\]git:$branch\[${PROMPT_COLORS[2]}\]) ")'

	# $ prompt character
	PS1+='\[${PROMPT_COLORS[0]}\]\$\[${COLOR256[256]}\] '

	set_prompt_colors 24

	# set terminal title: [ssh] user@host:path
	_prompt_command() {
		local user=$USER
		# short hostname
		local host=${HOSTNAME%%.*}
		# replace home with ~
		local pwd=${PWD/#$HOME/\~}
		local ssh=
		[[ -n $SSH_CLIENT ]] && ssh='[ssh] '
		printf '\033]0;%s%s@%s:%s\007' "$ssh" "$user" "$host" "$pwd"
	}
	PROMPT_COMMAND=_prompt_command

	# show last 6 dirs in prompt
	PROMPT_DIRTRIM=6
fi

# colored diff output
colordiff() {
	local red=$(tput setaf 1 2>/dev/null)
	local green=$(tput setaf 2 2>/dev/null)
	local cyan=$(tput setaf 6 2>/dev/null)
	local reset=$(tput sgr0 2>/dev/null)

	diff -u "$@" | awk "
	/^\-/ {
		printf(\"%s\", \"$red\");
	}
	/^\+/ {
		printf(\"%s\", \"$green\");
	}
	/^@/ {
		printf(\"%s\", \"$cyan\");
	}

	{
		print \$0 \"$reset\";
	}"

	return "${PIPESTATUS[0]}"
}

# display all 256 terminal colors
colors() {
	local i
	for i in {0..255}; do
		printf '\x1b[38;5;%dmcolor %d\n' "$i" "$i"
	done
	tput sgr0
}

# copy stdin to the clipboard
copy() {
	pbcopy 2>/dev/null ||
	    xsel 2>/dev/null ||
	    clip.exe

}

# convert unix timestamp to readable date
epoch() {
	# default: current time
	local num=${1:--1}
	printf '%(%B %d, %Y %-I:%M:%S %p %Z)T\n' "$num"
}

# mkdir and cd into it
mcd() {
	mkdir -p "$1" && cd "$1"
}

# open the current path or file in GitHub
gho() {
	local file=$1
	local remote=${2:-origin}

	# get the git root dir, branch, and remote URL
	local gr=$(git rev-parse --show-toplevel)
	local branch=$(git rev-parse --abbrev-ref HEAD)
	local url=$(git config --get "remote.$remote.url")

	[[ -n $gr && -n $branch && -n $remote ]] || return 1

	# construct the path
	local path=${PWD/#$gr/}
	[[ -n $file ]] && path+=/$file

	# extract the username and repo name
	local a
	IFS=:/ read -a a <<< "$url"
	local len=${#a[@]}
	local user=${a[len-2]}
	local repo=${a[len-1]%.git}

	url="https://github.com/$user/$repo/tree/$branch$path"
	echo "$url"
	open "$url"
}

# extract common archive formats
extract() {
	if [[ -f $1 ]]; then
		case $1 in
			*.tar.bz2) tar xjf "$1" ;;
			*.tar.gz)  tar xzf "$1" ;;
			*.tar.xz)  tar xJf "$1" ;;
			*.bz2)     bunzip2 "$1" ;;
			*.rar)     unrar e "$1" ;;
			*.gz)      gunzip "$1" ;;
			*.tar)     tar xf "$1" ;;
			*.tbz2)    tar xjf "$1" ;;
			*.tgz)     tar xzf "$1" ;;
			*.zip)     unzip "$1" ;;
			*.Z)       uncompress "$1" ;;
			*.7z)      7z x "$1" ;;
			*)         echo "'$1' cannot be extracted via extract()" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# platform-independent interfaces
interfaces() {
	node <<-EOF
	var os = require('os');
	var i = os.networkInterfaces();
	Object.keys(i).forEach(function(name) {
		i[name].forEach(function(int) {
			if (int.family === 'IPv4') {
				console.log('%s: %s', name, int.address);
			}
		});
	});
	EOF
}

# calculate CPU load / Core Count
load() {
	node -p <<-EOF
	var os = require('os');
	var c = os.cpus().length;
	os.loadavg().map(function(l) {
		return (l/c).toFixed(2);
	}).join(' ');
	EOF
}

# platform-independent memory usage
meminfo() {
	node <<-EOF
	var os = require('os');
	var free = os.freemem();
	var total = os.totalmem();
	var used = total - free;
	console.log('memory: %dmb / %dmb (%d%%)',
	    Math.round(used / 1024 / 1024),
	    Math.round(total / 1024 / 1024),
	    Math.round(used * 100 / total));
	EOF
}

# print lines over X columns (defaults to 80)
over() {
	awk -v c="${1:-80}" 'length($0) > c {
		printf("%4d %s\n", NR, $0);
	}'
}

# local overrides (not tracked in git)
. ~/.bashrc.local 2>/dev/null || true
. ~/.bash_aliases    2>/dev/null || true

# load bash completion
if [[ -n $BASH_VERSION ]]; then
	. /etc/bash_completion 2>/dev/null ||
		. /usr/share/bash-completion/bash_completion 2>/dev/null ||
		. ~/.bash_completion 2>/dev/null ||
		true
fi

# remove duplicate path entries (path_clean provided by bics)
[[ -n $BASH_VERSION ]] && path_clean

true
