#!/usr/bin/env bash
# Make the xenia monofont (https://github.com/Loretta1982/xenia) available to
# fontconfig, and hence to Emacs.
#
# Why this exists: rather than copying .ttf files into ~/.local/share/fonts,
# this clones the upstream repo into ~/dvcs/pcn and points fontconfig at the
# clone's fonts/ttf directory. Upstream updates then arrive with a plain
# `git pull` in the clone -- no re-download, no stale copies to notice and
# replace. The fonts are also never committed to this repo, which keeps ~15MB
# of binaries out of git and sidesteps xenia's licensing (free for personal,
# educational and open-source use; commercial use is a separate license).
#
# Idempotent: re-running pulls the clone and rebuilds the font cache.
#
# The family name Emacs wants is lowercase "xenia" -- see
# emacs/settings/early-misc.el.

set -e -o pipefail

CLONE_DIR="${XENIA_CLONE_DIR:-$HOME/dvcs/pcn/xenia}"
CONF_FILE="$HOME/.config/fontconfig/conf.d/60-xenia.conf"

if [ -d "$CLONE_DIR/.git" ]; then
    echo "Updating $CLONE_DIR"
    git -C "$CLONE_DIR" pull --ff-only
else
    echo "Cloning xenia into $CLONE_DIR"
    mkdir -p "$(dirname "$CLONE_DIR")"
    git clone https://github.com/Loretta1982/xenia.git "$CLONE_DIR"
fi

# A <dir> entry rather than a symlink into ~/.local/share/fonts: fontconfig
# reads the clone in place, so there is exactly one copy of the font on disk.
#
# The <match target="scan"> rules repair broken upstream metadata: as of this
# writing every xenia .ttf declares OS/2 usWeightClass=400 (Regular),
# including xenia_bold.ttf. Verify with:
#
#   fc-query -f '%{family[0]} %{style[0]} %{weight}\n' <file>.ttf
#
# Without these rules, fontconfig sees five faces of identical weight, so
# ":weight bold" cannot select Bold and the bare family "xenia" resolves
# arbitrarily (in practice to Bold, not Regular). Rewriting weight at scan
# time from the style name fixes weight selection for every application, not
# just Emacs. If upstream ever ships correct usWeightClass values these rules
# become harmless no-ops.
mkdir -p "$(dirname "$CONF_FILE")"
cat > "$CONF_FILE" <<CONF
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<!-- Managed by startup/linux/bin/install-xenia-font.sh; edits will be overwritten.
     A double hyphen is illegal inside an XML comment, so do not add one here. -->
<fontconfig>
  <dir>$CLONE_DIR/fonts/ttf</dir>

  <!-- The non-Regular faces report style as e.g. "Light,Regular", so the
       Regular rule matches them as well. It is listed first on purpose: later
       rules overwrite it, leaving each face with its specific weight. -->
  <match target="scan">
    <test name="family"><string>xenia</string></test>
    <test name="style"><string>Regular</string></test>
    <edit name="weight"><const>regular</const></edit>
  </match>
  <match target="scan">
    <test name="family"><string>xenia</string></test>
    <test name="style"><string>Light</string></test>
    <edit name="weight"><const>light</const></edit>
  </match>
  <match target="scan">
    <test name="family"><string>xenia</string></test>
    <test name="style"><string>Medium</string></test>
    <edit name="weight"><const>medium</const></edit>
  </match>
  <match target="scan">
    <test name="family"><string>xenia</string></test>
    <test name="style"><string>Semibold</string></test>
    <edit name="weight"><const>demibold</const></edit>
  </match>
  <match target="scan">
    <test name="family"><string>xenia</string></test>
    <test name="style"><string>Bold</string></test>
    <edit name="weight"><const>bold</const></edit>
  </match>
</fontconfig>
CONF

fc-cache -f > /dev/null

# Capture into a variable first: `fc-list | grep -q` under `set -o pipefail`
# fails the pipeline, because grep -q exits on the first match and fc-list then
# dies of SIGPIPE (141).
registered=$(fc-list | grep -i xenia || true)
if [ -n "$registered" ]; then
    echo "xenia registered with fontconfig:"
    echo "$registered"
else
    echo "xenia was NOT picked up by fontconfig; check $CONF_FILE" >&2
    exit 1
fi
