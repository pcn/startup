# Installing emacs 29+

Until ubuntu 24.x, the emacs is pretty old. So for now using a backported 
ubuntu build via a ppa is the easiest way to get emacs29.

https://ubuntuhandbook.org/index.php/2023/08/gnu-emacs-29-1-ubuntu-ppa/

```
sudo add-apt-repository ppa:ubuntuhandbook1/emacs
sudo apt install emacs
```

Link the files here into ~/.emacs.d
```
mkdir ~/.emacs.d
cd ~/.emacs.d
ln -s ~/dvcs/pcn/startup/emacs/{early-init.el,init.el,settings} .
```

Once that's in place, a new startup of emacs should load up all of the
required packages.
