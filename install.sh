#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Installing arch-cleaner...${NC}\n"

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

REPO="Praveensenpai/arch-cleaner"
RELEASE_URL="https://github.com/${REPO}/releases/latest/download/arch-cleaner-linux-x86_64.tar.gz"

LOCAL_DIR=""
if [ -n "${BASH_SOURCE[0]}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [ -n "$LOCAL_DIR" ] && [ -f "$LOCAL_DIR/Cargo.toml" ] && command -v cargo >/dev/null 2>&1; then
    echo -e "${BLUE}📦 Local source detected. Building release binary with Cargo...${NC}"
    cargo build --release --manifest-path "$LOCAL_DIR/Cargo.toml"
    cp "$LOCAL_DIR/target/release/arch-cleaner" "$BIN_DIR/arch-cleaner"
else
    echo -e "${BLUE}📦 Downloading latest pre-compiled Linux binary from GitHub Releases...${NC}"
    TMP_DIR=$(mktemp -d)
    if curl -4 -fL --connect-timeout 10 --retry 3 --progress-bar "$RELEASE_URL" -o "$TMP_DIR/arch-cleaner.tar.gz"; then
        tar -xzf "$TMP_DIR/arch-cleaner.tar.gz" -C "$TMP_DIR"
        if [ -f "$TMP_DIR/arch-cleaner" ]; then
            cp "$TMP_DIR/arch-cleaner" "$BIN_DIR/arch-cleaner"
        elif [ -f "$TMP_DIR/dist/arch-cleaner" ]; then
            cp "$TMP_DIR/dist/arch-cleaner" "$BIN_DIR/arch-cleaner"
        fi
        rm -rf "$TMP_DIR"
    else
        rm -rf "$TMP_DIR"
        echo -e "${RED}❌ Failed to download pre-compiled release. (Ensure a release tag like v0.1.0 exists on GitHub)${NC}"
        exit 1
    fi
fi

if [ ! -f "$BIN_DIR/arch-cleaner" ] || [ ! -s "$BIN_DIR/arch-cleaner" ]; then
    echo -e "${RED}❌ Error: Failed to install arch-cleaner binary!${NC}"
    exit 1
fi

chmod +x "$BIN_DIR/arch-cleaner"
echo -e "${GREEN}✔ Installed arch-cleaner to ${BIN_DIR}/arch-cleaner${NC}"

# Shell alias setup
SHELL_CONFIGS=("$HOME/.bashrc" "$HOME/.zshrc")
ALIAS_LINE="alias arch-cleaner='$HOME/.local/bin/arch-cleaner'"

for config in "${SHELL_CONFIGS[@]}"; do
    if [ -f "$config" ]; then
        if ! grep -q "alias arch-cleaner=" "$config" 2>/dev/null; then
            echo "" >> "$config"
            echo "$ALIAS_LINE" >> "$config"
            echo -e "${BLUE}📝 Added arch-cleaner alias to $config${NC}"
        fi
    fi
done

echo -e "\n${GREEN}${BOLD}🎉 arch-cleaner installation completed!${NC}"
echo -e "Run it anytime with: ${CYAN}arch-cleaner${NC}"
