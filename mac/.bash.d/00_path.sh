# -*- sh -*-

# Put this as the first file to be sourced.

if [ -z $PATH_SEEN ] ; then
    # Put /usr/local/bin and ~/bin before system defaults.
    PATH=~/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin

    # Try other things I'll probably have installed by now.
    for dir in /opt/chef/bin ; do
        if [ -d $dir ] ; then
            PATH=$PATH:$dir
        fi
    done

    export PATH
    export PATH_SEEN=true
fi
