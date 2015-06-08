#!/bin/bash

_rbenv() {
  COMPREPLY=()
  local word="${COMP_WORDS[COMP_CWORD]}"

  if [ "$COMP_CWORD" -eq 1 ]; then
    COMPREPLY=( $(compgen -W "$(rbenv commands)" -- "$word") )
  else
    local words=("${COMP_WORDS[@]}")
    unset words[0]
    unset words[$COMP_CWORD]
    local completions=$(rbenv completions "${words[@]}")
    COMPREPLY=( $(compgen -W "$completions" -- "$word") )
  fi
}

# If we have pyenv installed initialize its
if [ $(which rbenv | wc -l) -eq 1 ] ; then
    # Load pyenv automatically by adding
    # the following to the end of ~/.bash_profile:
    eval "$(rbenv init -)"
    complete -F _rbenv rbenv
fi
