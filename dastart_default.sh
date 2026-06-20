#!/bin/bash

set -e

LOG="/var/log/daos/democonfig.log"

# Define home folders
DISTRO_HOME="/home/daos"
MY_HOME="/home/da"
SCRIPT_DIR="$DISTRO_HOME/default"

mkdir -p /workspaces
mkdir -p /mnt/p1

echo "1" > "$LOG"

# relocate my daily scripts
PER_SRC="/tmp/dainit/daspaces"
PER_DEST="$DISTRO_HOME"

if [ -d "$PER_SRC" ]; then
    cp -fr "$PER_SRC"/. "$PER_DEST"/
else
    echo "Directory does not exist: $PER_SRC" >> "$LOG"
fi

{
GITCONFIG="$MY_HOME/.gitconfig"
cat > "$GITCONFIG" <<EOF
[user]
    name = daos
    email = daos@dage.party
EOF
chmod 644 "$GITCONFIG"
} || echo "git user config error" >> "$LOG"

echo "2" >> "$LOG"

cd "$DISTRO_HOME"
mkdir -p "runCommand"


{
if [ -d "$SCRIPT_DIR/ffprofile" ]; then
    mkdir -p "$DISTRO_HOME/.config"
    mv "$SCRIPT_DIR/ffprofile" "$DISTRO_HOME/.config/"
fi
} || echo "ffprofile move error" >> "$LOG"

##### .runCommand section
{
if [ -d "$DISTRO_HOME/.runCommand" ]; then
    if [ -d "$DISTRO_HOME/runCommand" ]; then
        cp -a "$DISTRO_HOME/runCommand/." "$DISTRO_HOME/.runCommand/"
        rm -fr "$DISTRO_HOME/runCommand/"
    fi
else
    if [ -d "$DISTRO_HOME/runCommand" ]; then
        mv "$DISTRO_HOME/runCommand" "$DISTRO_HOME/.runCommand"
    else
        mkdir -p "$DISTRO_HOME/.runCommand"
    fi
fi

cp -a "$SCRIPT_DIR/runCommand/." "$DISTRO_HOME/.runCommand/"
chmod +x "$DISTRO_HOME/.runCommand/"*

cat > "$DISTRO_HOME/.runCommand/.bashrc" <<EOF
export PATH=\$PATH:$DISTRO_HOME/.runCommand
cd /home/daos
EOF

} || echo "runCommand combine error" >> "$LOG"

{
grep -qxF "source $DISTRO_HOME/.runCommand/.bashrc" "$MY_HOME/.bashrc" || \
echo "source $DISTRO_HOME/.runCommand/.bashrc" >> "$MY_HOME/.bashrc"
} || true

mkdir -p "$DISTRO_HOME/.software"
mkdir -p "$DISTRO_HOME/.udff"

chown -R 1000:1000 "$DISTRO_HOME"/
chown -R 1000:1000 "$MY_HOME"/

echo "3" >> "$LOG"

# souonds hardware fix
{
tee /etc/asound.conf << 'EOF'
defaults.pcm.card 0
defaults.ctl.card 0

pcm.!default {
    type hw
    card 0
}

ctl.!default {
    type hw
    card 0
}
EOF

sudo alsa force-reload

amixer set Master 80% unmute     2>/dev/null
amixer set PCM 85% unmute        2>/dev/null
amixer set Speaker 85% unmute    2>/dev/null
amixer set Headphone 85% unmute  2>/dev/null
amixer set 'Headset' 85% unmute  2>/dev/null
} || echo "souonds config error" >> "$LOG"


# install chinese font
{
curl -fLO -o wqy-microhei.ttc "https://www.dropbox.com/scl/fi/sxzylmp8obyaklyz492tk/wqy-microhei.ttc?rlkey=kd40a6lfbi8lbzxcicoeyfyf0&st=hxonagzy&dl=1"
mkdir -p /usr/share/fonts/truetype/wqy
mv  wqy-microhei.ttc /usr/share/fonts/truetype/wqy/
} || echo "font install error" >> "$LOG"

# install firefox, if it's not exists
install_firefox() {
    local DEST="$DISTRO_HOME/.software/firefox"
    local TEMPPATH="/tmp/firefox"

    # Check if Firefox is already installed and executable
    if [ -x "$DEST/firefox" ]; then
        return 0
    fi

    rm -rf "$DEST"
    mkdir -p "$DEST" || return 1
    mkdir -p "$TEMPPATH" || return 1
    cd "$TEMPPATH" || return 1
    
    # Clean up any old partial downloads
    rm -f firefox128.tar.xz

    # Download the split archive components
    curl -fLO -o firefox128.tar.xz "https://www.dropbox.com/scl/fi/mwic29zlagvmlgzxjlgt0/firefox128.tar.xz?rlkey=hbcmrcmera8474kj2zu8pdzbg&st=gtwrak6w&dl=1" || return 1

    # Extract the tarball
    tar -xJf firefox128.tar.xz -C "$DEST" --strip-components=1 || return 1

    # Clean up temp folder completely
    rm -rf "$TEMPPATH"

    # Verify the installation was successful
    if [ -x "$DEST/firefox" ]; then
        echo "✔ Firefox 128 installed" >> "$LOG"
        return 0
    else
        echo "✘ Error: firefox binary not found in $DEST" >> "$LOG"
        return 1
    fi
}
install_firefox || echo "firefox install error" >> "$LOG"

echo "4" >> "$LOG"

{
    apt install -y git xclip
} || echo  "apt install git error" >> "$LOG"


# {
# curl -LO https://github.com/neovim/neovim/releases/latest/download/nvim-linux-x86_64.tar.gz
# tar xzf nvim-linux-x86_64.tar.gz
# } || true

# {
# if git clone --depth=1 https://github.com/LazyVim/starter "$MY_HOME/.config/nvim"; then
#     rm -rf "$MY_HOME/.config/nvim/.git"
#     chown -R 1000:1000 "$MY_HOME/.config"
# else
#     echo "nvim config clone error" >> "$LOG"
# fi
# } || echo "LazyVim config clone error" >> "$LOG"


chown -R 1000:1000 "$DISTRO_HOME"/
chown -R 1000:1000 "$MY_HOME"/


echo "5" >> "$LOG"
