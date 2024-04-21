# Not using guix for emacs with native-comp

# if [ -f $HOME/.config/guix/current/etc/profile ]  ; then
#     GUIX_PROFILE=~/.config/guix/current
#     . "$GUIX_PROFILE/etc/profile"
#     # pop-os has a bug with this symlink in my home dir:
#     # https://github.com/pop-os/shell/issues/1544
#     # it looks like that's just a default manifest, so I'm
#     # going to see if I can specify an alternative manifest,
#     # based on what I'm reading at
#     # https://guix.gnu.org/cookbook/en/html_node/Basic-setup-with-manifests.html
#     # and put it outside of my home dir to avoid pop-os breaking, hopefully
#     export GUIX_LOCPATH=$HOME/.guix-profile/lib/locale
    
#     # Automatically added by the Guix install script.
#     if [ -n "$GUIX_ENVIRONMENT" ]; then
#         if [[ $PS1 =~ (.*)"\\$" ]]; then
#             PS1="${BASH_REMATCH[1]} [env]\\\$ "
#         fi
#     fi
# else
#     cat <<EOF
# guix doesn't seem to be installed. Please follow the instructions at
# https://www.ubuntubuzz.com/2021/04/lets-try-guix.html.

# This was installed for emacs with native comp from:
# https://github.com/flatwhatson/guix-channel
# EOF
# fi

