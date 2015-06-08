#!/bin/bash

_pyenv() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(pyenv commands)" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    unset words[$COMP_CWORD]
    local completions=$(pyenv completions "${words[@]}")
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}


# If we have pyenv installed initialize its
if [ $(which pyenv | wc -l) -eq 1 ] ; then
    # Load pyenv automatically by adding
    # the following to the end of ~/.bash_profile:
    eval "$(pyenv init -)"
    complete -F _pyenv pyenv
fi
if which pyenv-virtualenv-init > /dev/null; then eval "$(pyenv virtualenv-init -)"; fi
