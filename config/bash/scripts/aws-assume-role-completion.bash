#/usr/bin/env bash

function _aws-assume-role_completions {
   PROFILES=$(sed -nE 's/\[profile ([^]]+)\]/\1/p' ~/.aws/config)
   COMPREPLY=($(compgen -W "${PROFILES}" -- "${COMP_WORDS[1]}"))
}

complete -F _aws-assume-role_completions assume-role
