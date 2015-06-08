#!/bin/bash

# If we have pyenv installed initialize its
if [ $(which rbenv | wc -l) -eq 1 ] ; then
    # Load pyenv automatically by adding
    # the following to the end of ~/.bash_profile:
    eval "$(rbenv init -)"
fi
