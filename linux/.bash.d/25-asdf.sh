# For netlify, install asdf
if [ -d $HOME/.asdf ]  ; then
   . $HOME/.asdf/asdf.sh
   . $HOME/.asdf/completions/asdf.bash
else
    echo "You're missing an asdf installation. Follow the instructions at https://asdf-vm.com/ if you want it"
fi
