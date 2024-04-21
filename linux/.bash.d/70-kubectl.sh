#!/bin/bash

# alias kubectl='docker exec k0s-controller kubectl'
if [ "x$(type -t kubectl)" != "x" ] ; then

    source <(kubectl completion bash)
    source ~/dvcs/github/kubectx/completion/*.bash
    # alias k='docker exec k0s-controller kubectl'
    # alias mk="microk8s kubectl"
    alias k="kubectl"
else
    echo "You don't have kubectl installed, skipping"
fi

