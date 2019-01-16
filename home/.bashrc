# Shrike's .bashrc

# https://wiki.archlinux.org/index.php/Color_Bash_Prompt
# https://github.com/ijonas/dotfiles/blob/master/bash/config

# If not running interactively, don't do anything
[ -z "$PS1" ] && return

stty stop undef
stty start undef

export DISPLAY=

# emacsd setup
# Run emacs-server if needed
export ALTERNATE_EDITOR=""
export EDITOR="emacsclient -nw -c"$@""
alias emacs="$EDITOR"

export TERM="screen-256color"

# hm?
export GCAL='--iso-week-number=yes --with-week-number --starting-day=Monday'

# don't put duplicate lines in the history. See bash(1) for more options
# don't overwrite GNU Midnight Commander's setting of `ignorespace'.
#export HISTCONTROL=$HISTCONTROL${HISTCONTROL+,}ignoredups
# ... or force ignoredups and ignorespace
export HISTCONTROL="ignoreboth"
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S  "
# ignore some boring stuff. The " *" bit ignores all command lines
# starting with whitespace, useful to selectively avoid the history
export HISTIGNORE="cd:cd ..:..*: *"

export PYTHONSTARTUP="$HOME/.pystartup"
# allow easy_install -d ~/bin/ <packagename> to work
export PYTHONPATH=$PYTHONPATH:$HOME/site-packages/
# pip install --user
export PYTHONPATH=$PYTHONPATH:$HOME/.local/bin/

# append to the history file, don't overwrite it
shopt -s histappend

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "$debian_chroot" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

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
    #PROMPT_COMMAND='echo -ne "\033]0;${LOGNAME}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    # diz no worky, need to add $PS1 somewhere
    #PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
    ;;
screen)
    #PROMPT_COMMAND='echo -ne "\033]0;${LOGNAME}@${HOSTNAME}: ${PWD/$HOME/~}\007"'
    #PS1='\[\033k\033\\\]\u@\h:\w\$ '
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    eval "$(dircolors -b)"
    alias ls='ls --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'

    alias rm='rm -I'
fi

# create search database to current directory
function create_searchdb {
  updatedb -l 0 -o locatedb --database-root $(pwd)
}
# search from the current tree using an optimized database if available
function search {
  # recursive upwards search for a locate db in this tree
  local p="$(pwd)/";
  while [ "$p" != "/" ];
  do
    if [ -e "$p/locatedb" ];
    then
      local db="$p"locatedb;
    fi;
    p="${p%/*/}/";
  done;
  # if there is a pregenerated db, use it
  # otherwise revert to global db
  if [[ "$db" == "" ]];
  then
    locate -e -i "$@";
  else
    locate -e -i -d "$db" "$@";
  fi
}

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
fi

# gist user installs
if [ -d $HOME/.gem/ruby/1.9.1/bin ] ; then
    PATH=$HOME/.gem/ruby/1.9.1/bin:"${PATH}"
fi

# local binaries
if [ -d $HOME/bin ] ; then
    PATH=$HOME/bin:"${PATH}"
fi
# local binaries for pip install --user
if [ -d $HOME/.local/bin ] ; then
    PATH=$HOME/.local/bin:"${PATH}"
fi

# for emacs..
#export TERM=xterm-256color

# xterm-256color breaks irssi scrolling completely under tmux
alias irssi="TERM=screen irssi"

# .env support
# https://github.com/kennethreitz/autoenv
source ~/dotconf/activate.sh

# Thanks to https://gist.github.com/634750

RED="\[\033[0;31m\]"
YELLOW="\[\033[0;33m\]"
GREEN="\[\033[0;32m\]"
BLUE="\[\033[0;34m\]"
LIGHT_RED="\[\033[1;31m\]"
LIGHT_GREEN="\[\033[1;32m\]"
WHITE="\[\033[1;37m\]"
LIGHT_GRAY="\[\033[0;37m\]"
COLOR_NONE="\[\e[0m\]"

function generate_git_bar {
  git_status="$(git status 2> /dev/null)"
  branch_pattern="On branch ([^${IFS}]*)"
  detached_branch_pattern="Not currently on any branch"
  remote_pattern="Your branch is (.*) of"
  diverge_pattern="Your branch and (.*) have diverged"
  detached_at_pattern="HEAD detached at ([^${IFS}]*)"

  if [[ ${git_status}} =~ "Changed but not updated" ]]; then
    flags="${RED}?" # Old git???
  fi

  if [[ ${git_status}} =~ "Untracked files" ]]; then
    flags="${flags}${RED}!"
  fi

  if [[ ${git_status}} =~ "Changes not staged for commit" ]]; then
    flags="${flags}${RED}⚡"
  fi

  if [[ ${git_status}} =~ "Changes to be committed" ]]; then
    flags="${flags}${RED}√"
  fi

  if [[ ${git_status}} =~ "Unmerged paths" ]]; then
    flags="${flags}${RED}≈"
  fi

  # stuff in stash
  if [ "$(git stash list)" ]; then
    flags="${flags}${RED}˷"
  fi

  if [[ ${git_status} =~ ${remote_pattern} ]]; then
    if [[ ${BASH_REMATCH[1]} == "ahead" ]]; then
      flags="${flags}${YELLOW}↑"
    else
      flags="${flags}${YELLOW}↓"
    fi
  fi

  if [[ ${git_status} =~ ${diverge_pattern} ]]; then
    flags="${flags}${YELLOW}↕"
  fi

  if [[ ${git_status} =~ ${branch_pattern} ]]; then
    branch="${LIGHT_GRAY}${BASH_REMATCH[1]}"
  elif [[ ${git_status} =~ ${detached_branch_pattern} ]]; then
    branch="${RED}NO BRANCH"
  elif [[ ${git_status} =~ ${detached_at_pattern} ]]; then
    branch="${RED}${BASH_REMATCH[1]}"
  fi


  if [ "${flags}" ]; then
    flags="${COLOR_NONE}|${flags}"
  fi

  echo "${COLOR_NONE}(${branch}${COLOR_NONE}${flags}${COLOR_NONE})"
}

function generate_virtualenv_bar {
    if test -z "$VIRTUAL_ENV" ; then
        PYTHON_VIRTUALENV=""
    else
        PYTHON_VIRTUALENV="${LIGHT_GREEN}[`basename \"$VIRTUAL_ENV\"`]${COLOR_NONE} "
    fi

    echo $PYTHON_VIRTUALENV
}

function stopped_jobs(){
  if [  "$(jobs 2>&1)" != "" ]; then
    echo "${COLOR_NONE}(${RED}bg${COLOR_NONE})"
  fi
}

function tmux_bg(){
  # if not inside tmux check for existing detached tmux sessions
  if [ "${TMUX:-}" = "" ]; then
    tmux ls > /dev/null 2>&1 && {
      echo "${COLOR_NONE}(${GREEN}tmux${COLOR_NONE})"
    }
  fi
}

function prompt_func() {
  exit_status=$?
  local _jobs=$(stopped_jobs)

  # Use red # as prompt char when root
  if [ $(id -u) -eq 0 ]; then
    prompt_char="# "
    host="${RED}\u@\h"
  else
    prompt_char="$ "
    host="${GREEN}\u@\h"
  fi

  # Tun prompt char to red if the last command failed
  if [ ! ${exit_status} -eq 0 ]; then
    prompt_char="${RED}${prompt_char}${COLOR_NONE}"
  else
    prompt_char="${COLOR_NONE}${prompt_char}"
  fi

  # titlebar = line above prompt
  # user@host $PWD
  titlebar="${host} ${YELLOW}\w"

  # Git repo detection & git-bar
  git rev-parse --git-dir > /dev/null 2>&1
  if [ $? -eq 0 ]; then
    # In Git repo
    git_bar="$(generate_git_bar)"
  else
    git_bar=""
  fi

  virtualenv_bar="$(generate_virtualenv_bar)"

  PS1="${titlebar}\n${_jobs}$(tmux_bg)${virtualenv_bar}${git_bar}${prompt_char}"
  title="\033]0;"
  # SSH connection to host, display host name in title
  if [ "$SSH_CONNECTION" != "" -o "${USER}" = "root" ]; then
    title="${title}$(echo $HOSTNAME|cut -d . -f 1): "
  fi
  title="${title}${PWD/$HOME/~}\007"

  # Append last command to ~/.bash_history
  history -a
  # set terminal title
  echo -ne $title
}

PROMPT_COMMAND=prompt_func

# add export variables for local perl installs when needed
# http://search.cpan.org/~miyagawa/App-cpanminus-1.4008/lib/App/cpanminus.pm
#
# install:
# curl -L http://cpanmin.us | perl - App::cpanminus
# install packages:
# curl -L http://cpanmin.us | perl - Net::Twitter

if [ -d $HOME/perl5 ] ; then
eval `perl -I ~/perl5/lib/perl5 -Mlocal::lib`
fi

# added by travis gem
[ -f /home/users/shrike/.travis/travis.sh ] && source /home/users/shrike/.travis/travis.sh

source "$HOME/.homesick/repos/homeshick/homeshick.sh"
source "$HOME/.homesick/repos/homeshick/completions/homeshick-completion.bash"
homeshick --quiet refresh