#!/bin/bash

# Use the starship PS1 setter
# https://starship.rs/config/
if [ "$(type -f -t starship)" == "file" ] ; then
    eval "$(starship init bash)"
else
    echo "starship not found"
fi

