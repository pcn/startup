# Load pyenv automatically by adding
# the following to ~/.bash_profile:

if [ -f .pyenv/bin/pyenv ] ; then
    export PATH="~/.pyenv/bin:$PATH"
    eval "$(pyenv init -)"
    eval "$(pyenv virtualenv-init -)"
else
    echo "You don't have pyenv installed, skipping"
fi
