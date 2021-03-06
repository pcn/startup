# -*- bash -*-

# Use this when virtualenvwrapper is in the path

# I'll always use ~/venv as my virtualenv home

if [ $(which virtualenvwrapper.sh 2>/dev/null | wc -l) -eq 1 ] ; then
    export WORKON_HOME=~/venv

    if [ ! -d $WORKON_HOME ] ; then
        mkdir -p $WORKON_HOME
    fi

    WRAPPER=$(which virtualenvwrapper.sh | head -1 ) # take the first one.

    if [ ! -d $WORKON_HOME/python ] ; then
        mkvirtualenv python
    fi

    source $WRAPPER
fi
