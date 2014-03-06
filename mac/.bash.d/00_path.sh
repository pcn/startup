# -*- sh -*-

# Put this as the first file to be sourced.

if [ -z $PATH_SEEN ] ; then
    # Put /usr/local/bin and ~/bin before system defaults.
    export PATH=~/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
    export PATH_SEEN=true
fi
