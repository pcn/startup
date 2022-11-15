if [ -f $HOME/.config/guix/current/etc/profile ]  ; then
    GUIX_PROFILE=~/.config/guix/current
    . "$GUIX_PROFILE/etc/profile"
    export GUIX_LOCPATH=$HOME/.guix-profile/lib/locale    
    
else
    cat <<EOF
guix doesn't seem to be installed. Please follow the instructions at
https://www.ubuntubuzz.com/2021/04/lets-try-guix.html.

This was installed for emacs with native comp from:
https://github.com/flatwhatson/guix-channel
EOF
fi

