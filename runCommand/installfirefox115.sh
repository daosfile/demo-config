#!/bin/bash

# Configuration
DISTRO_HOME="/home/daos"
DEST="$DISTRO_HOME/.software/firefox115"

# Color codes for clean terminal output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Install Firefox 115esr if it doesn't exist
if [ ! -x "$DEST/firefox" ]; then
    echo "Installing Firefox 115esr..."
    
    # Create a secure temporary directory for downloading/assembling chunks
    TMP_DIR=$(mktemp -d)
    cd "$TMP_DIR" || exit 1

    curl -fLO -o firefox115.tar.xz "https://www.dropbox.com/scl/fi/f0sph4i8p2a3iemrwgv93/firefox115.tar.xz?rlkey=aek7m9u9w2s67hsmskaa7u7d9&st=x3zwk8ab&dl=1" || return 1

    # Prepare destination directory
    rm -rf "$DEST"
    mkdir -p "$DEST"

    # Extract the archive
    tar -xJf firefox115.tar.xz -C "$DEST" --strip-components=1 || exit 1

    # Clean up the temporary directory automatically
    rm -rf "$TMP_DIR"

    # Verify installation
    if [ -x "$DEST/firefox" ]; then
        echo -e "${GREEN}✔ Firefox 115esr installed successfully${NC}"
    else
        echo -e "${RED}✘ Error: firefox binary not found in $DEST${NC}" >&2
        exit 1
    fi
else
    echo "Firefox 115esr is already installed at $DEST."
fi
