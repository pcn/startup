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

# Fonts

The default face uses the [xenia monofont](https://github.com/Loretta1982/xenia),
which is not packaged. Install it with:

```
~/dvcs/pcn/startup/linux/bin/install-xenia-font.sh
```

That clones the font repo to `~/dvcs/pcn/xenia` and points fontconfig at the
clone, so `git pull` there is enough to pick up upstream changes. It also
writes fontconfig rules that correct the font's weight metadata -- every xenia
.ttf ships claiming to be Regular, so without the fixup Emacs cannot tell the
weights apart. Re-run the script if a weight renders as the wrong face.

Emacs skips the font if it is not installed, so init still works on a machine
where you have not run the script.
