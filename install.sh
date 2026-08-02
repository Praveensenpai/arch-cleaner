#!/bin/bash

CYAN='\033[0;36m'
GREEN='\033[0;32m'
PURPLE='\033[0;35m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${PURPLE}🚀 Installing arch-cleaner (Rust)...${NC}\n"

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

LOCAL_DIR=""
if [ -n "${BASH_SOURCE[0]}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
    LOCAL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" 2>/dev/null && pwd)"
fi

if [ -n "$LOCAL_DIR" ] && [ -f "$LOCAL_DIR/Cargo.toml" ]; then
    echo -e "${BLUE}📦 Building Rust release binary...${NC}"
    cargo build --release --manifest-path "$LOCAL_DIR/Cargo.toml"
    cp "$LOCAL_DIR/target/release/arch-cleaner" "$BIN_DIR/arch-cleaner"
else
    RAW_URL="https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/bin/arch-cleaner"
    echo -e "${BLUE}📦 Downloading arch-cleaner binary from GitHub...${NC}"
    curl -sSL -H 'Cache-Control: no-cache' "$RAW_URL" -o "$BIN_DIR/arch-cleaner"
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
