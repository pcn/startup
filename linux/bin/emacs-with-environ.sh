#!/bin/bash

# Run from .local/share/applications/emacs.desktop

# For launching emacs after sourcing pyenv startup functions
[ -f ~/.bash.d/30-pyenv.sh ] && . ~/.bash.d/30-pyenv.sh
# [ -f ~/.bash.d/31-golang.sh  ] && . ~/.bash.d/31-golang.sh 
[ -f ~/.cargo/env ] && . ~/.cargo/env

ssh-add ~/.ssh/id_rsa
ssh-add ~/.ssh/id_github

export PATH=$PATH:$HOME/bin:$HOME/go/bin

# set -x
# export LD_LIBRARY_PATH=$(ls -1 $(find $(dirname $(dirname $(readlink  --canonicalize ~/bin/emacs))) -type d -name native-lisp ) | head -1)

# Using guix instead now?
# exec $(readlink --canonicalize /home/spacey/bin/emacs) "$@" &

export PATH="~/.guix-profile/bin:$PATH"
export EMACSLOADPATH="~/.guix-profile/share/emacs/site-lisp"
export INFOPATH="~/.guix-profile/share/info"

exec emacs "$@"
