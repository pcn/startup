# For netlify, install asdf
if [ -d $HOME/.asdf ]  ; then
   . $HOME/.asdf/asdf.sh
   . $HOME/.asdf/completions/asdf.bash
else
    echo "You're missing an asdf installation. Follow the instructions at https://asdf-vm.com/ if you want it"
fi


# After installing, let's log some of the things I'm using it for
# nodejs
# https://github.com/asdf-vm/asdf-nodejs
# asdf plugin add nodejs https://github.com/asdf-vm/asdf-nodejs.git; asdf install nodejs latest; asdf global nodejs latest
#
# golang
# https://github.com/kennyp/asdf-golang
# asdf plugin-add golang https://github.com/kennyp/asdf-golang.git; asdf install golang latest; asdf global golang latest
# Note:
#  asdf reshim golang
# after `go get` or `go install`
export ASDF_GOLANG_DEFAULT_PACKAGES_FILE=~/.bash.d/asdf-default-golang-pkgs


