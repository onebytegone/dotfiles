platform=`uname | awk '{print tolower($0)}'`

source ./config/collector.bash

if [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
else
   alias ls='ls -G'
fi

alias ll='ls -alF'


alias ag='ag --pager=less'
alias grep='grep --color=auto'

export LESS="-RinSFX"
export LSCOLORS=ExFxCxDxBxegedabagacad

