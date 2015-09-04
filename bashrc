platform=`uname | awk '{print tolower($0)}'`

if [[ $platform == 'linux' ]]; then
   alias ls='ls --color=auto'
else
   alias ls='ls -G'
fi

alias ll='ls -alF'

