# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
#force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
    else
	color_prompt=
    fi
fi

if [ "$color_prompt" = yes ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
else
    PS1='${debian_chroot:+($debian_chroot)}\u@\h:\w\$ '
fi
unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

. "$HOME/.turso/env"

# CPU Profiler aliases
alias cpu-profile='/home/devansh/Downloads/jetson_cpu_profiler_v1.0/cpu_profiler.sh'
alias cpu-event='/home/devansh/Downloads/jetson_cpu_profiler_v1.0/log_event.sh'
alias cpu-analyze='/home/devansh/Downloads/jetson_cpu_profiler_v1.0/analyze_profile.py'
alias cpu-compare='/home/devansh/Downloads/jetson_cpu_profiler_v1.0/compare_profiles.py'
alias cpu-dashboard='/home/devansh/Downloads/jetson_cpu_profiler_v1.0/dashboard.py'
export PATH="$HOME/.local/bin:$PATH"
export PATH=$PATH:/usr/local/go/bin

# opencode
export PATH=/home/devansh/.opencode/bin:$PATH

# 10xSim Isaac Sim Controller GUI alias - added by setup_alias.sh
alias start-10xsim='/home/devansh/10xSim/start_sim_ui.sh'
. "$HOME/.cargo/env"

alias sally="CLAUDE_CONFIG_DIR=~/.claude-sally claude"

# arfath profile: its own config dir (settings/auth/plugins), but shares the
# default Claude's chat history and per-project memory.
#   chat  -> ~/.claude-arfath/projects is a symlink to ~/.claude/projects
#   memory-> passed per-launch below, because the auto-memory permission guard
#            resolves symlinks and blocks a symlinked memory/ dir.
arfath() {
  local slug mem
  slug=$(printf '%s' "$PWD" | sed 's/[^a-zA-Z0-9]/-/g')
  mem="$HOME/.claude/projects/$slug/memory"
  mkdir -p "$mem"
  CLAUDE_CONFIG_DIR="$HOME/.claude-arfath" \
    claude --settings "{\"autoMemoryDirectory\":\"$mem\"}" "$@"
}

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


dev() {
    cd /home/devansh/Desktop/code/cc-dev && ./cli
}
export PATH="/opt/zig:$PATH"


ved() {
  local name=${1:-default}
  local config="$HOME/.claude-envs/$name"

  mkdir -p "$config"

  CLAUDE_CONFIG_DIR="$config" claude
}
# launch Obsidian detached: no terminal noise, survives closing the shell
obsidian() {
  setsid /snap/bin/obsidian "$@" >/dev/null 2>&1 < /dev/null &
  disown
}


# >>> tmux-resurrect: save after every command, record last command >>>
_tmux_rs_prompt() {
	[ -n "$TMUX" ] || return 0
	[ "$TMUX_RS_AUTOSAVE" = "0" ] && return 0

	local rs_dir="$HOME/.local/share/tmux/resurrect"
	local key cmd tmp

	key=$(tmux display -p '#{session_name}:#{window_index}.#{pane_index}' 2>/dev/null)
	[ -n "$key" ] || return 0

	# Last command, minus the leading history number.
	cmd=$(history 1 | sed 's/^[[:space:]]*[0-9]\+[[:space:]]*//')

	# The sidecar is plaintext on disk -- don't record anything credential-shaped.
	case "$cmd" in
		*TOKEN=*|*KEY=*|*SECRET=*|*PASSWORD=*|*PASSWD=*|*Authorization*|*authorization*) cmd="" ;;
	esac

	if [ -n "$cmd" ]; then
		mkdir -p "$rs_dir"
		tmp=$(mktemp "$rs_dir/.lc.XXXXXX" 2>/dev/null)
		if [ -n "$tmp" ]; then
			[ -f "$rs_dir/last-commands" ] &&
				grep -vF "$key	" "$rs_dir/last-commands" > "$tmp" 2>/dev/null
			printf '%s\t%s\n' "$key" "$cmd" >> "$tmp"
			mv -f "$tmp" "$rs_dir/last-commands"
			chmod 600 "$rs_dir/last-commands"
		fi
	fi

	# Detached, so the prompt never waits on the save.
	setsid "$HOME/.local/bin/tmux-rs-save.sh" >/dev/null 2>&1 &
}
PROMPT_COMMAND=_tmux_rs_prompt
# <<< tmux-resurrect <<<

# >>> grok installer >>>
export PATH="$HOME/.grok/bin:$PATH"
[[ -r "$HOME/.grok/completions/bash/grok.bash" ]] && source "$HOME/.grok/completions/bash/grok.bash"
# <<< grok installer <<<
