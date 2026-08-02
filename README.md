# 🧹 arch-cleaner

Interactive system cache, systemd journal log, and user trash cleanup utility for **Arch Linux**.

---

## ✨ Features

- 🧹 **Pacman & Yay Cache**: Clean cached package downloads safely.
- 📜 **Systemd Journal Vacuum**: Limit journal disk usage to 50MB.
- 🗑️ **User Trash**: Empty user trash files and metadata.
- 🖼️ **Thumbnail Cache**: Clear thumbnail previews cache.

---

## 📦 Installation

> ℹ️ **Note**: AUR submission (`yay -S arch-cleaner-git`) is currently pending due to temporary AUR maintenance. Please use the one-liner installer below in the meantime.

### Quick One-Liner

```bash
curl -sSL https://raw.githubusercontent.com/Praveensenpai/arch-cleaner/main/install.sh | bash
```

### 🛠️ Build from Source (Cargo)

Prerequisites: [Rust & Cargo](https://rustup.rs/)

```bash
git clone https://github.com/Praveensenpai/arch-cleaner.git
cd arch-cleaner
cargo build --release
cp target/release/arch-cleaner ~/.local/bin/
```

---

## ⚡ Usage

```bash
arch-cleaner
```

---

## 📜 License

MIT
