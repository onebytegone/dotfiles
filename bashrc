platform=`uname | awk '{print tolower($0)}'`

source ./scripts/collector.bash


#####################
# File listing
#####################

if [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
else
   alias ls='ls -G'
fi

alias ll='ls -alF'


#####################
# Searching
#####################

alias ag='ag --pager=less'
alias grep='grep --color=auto'


#####################
# `less` settings
#####################

export LESS="-RinSFX"
export LSCOLORS=ExFxCxDxBxegedabagacad


#####################
# Increase history
#####################

HISTSIZE=10000
HISTFILESIZE=400000

shopt -s histappend
