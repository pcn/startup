#!/bin/bash
set -e -o pipefail
# Run from .local/share/applications/emacs.desktop

# For launching emacs after sourcing pyenv startup functions
[ -f ~/.bash.d/30-pyenv.sh ] && . ~/.bash.d/30-pyenv.sh
# [ -f ~/.bash.d/31-golang.sh  ] && . ~/.bash.d/31-golang.sh  # Use asdf instead
[ -f ~/.bash.d/25-asdf.sh ] && . ~/.bash.d/25-asdf.sh
[ -f ~/.cargo/env ] && . ~/.cargo/env

[ -f ~/.ssh/id_rsa ] && ssh-add ~/.ssh/id_rsa
[ -f ~/.ssh/id_github ] && ssh-add ~/.ssh/id_github
[ -f ~/.ssh/id_ed25519 ] && ssh-add ~/.ssh/id_ed25519
[ -f ~/.ssh/id_github_ed25519 ] && ssh-add ~/.ssh/id_github_ed25519


export PATH=$PATH:$HOME/bin:/usr/local/go/bin

# set -x
# export LD_LIBRARY_PATH=$(ls -1 $(find $(dirname $(dirname $(readlink  --canonicalize ~/bin/emacs))) -type d -name native-lisp ) | head -1)

# Using guix instead now?
# exec $(readlink --canonicalize /home/spacey/bin/emacs) "$@" &

export PATH="~/.guix-profile/bin:$PATH"
#  export EMACSLOADPATH="~/.guix-profile/share/emacs/site-lisp"
export INFOPATH="~/.guix-profile/share/info"

# exec emacs --init-directory=~/.emacs.d "$@"
exec ~/emacs/30-rc1/bin/emacs "$@"
