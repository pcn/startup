# Put this as the first file to be sourced.

if [ -z $GO_PATH_SEEN ] ; then
    # Put /usr/local/bin and ~/bin before system defaults.
    export GOPATH=~/dvcs/golang
    export PATH=$PATH:/usr/local/go/bin

    export GO_PATH_SEEN=true
fi
