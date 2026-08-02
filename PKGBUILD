# Maintainer: Praveen <praveen@local>
pkgname=arch-cleaner-git
pkgver=1.0.0
pkgrel=1
pkgdesc="Interactive package cache, systemd journal log, and trash cleanup utility for Arch Linux"
arch=('any')
url="https://github.com/Praveensenpai/arch-cleaner"
license=('MIT')
depends=('bash' 'pacman' 'systemd')
makedepends=('git')
provides=('arch-cleaner')
conflicts=('arch-cleaner')
source=("git+https://github.com/Praveensenpai/arch-cleaner.git")
sha256sums=('SKIP')

pkgver() {
  cd "$srcdir/${pkgname%-git}" 2>/dev/null || cd "$srcdir"
  git describe --long --tags 2>/dev/null | sed 's/\([^-]*-g\)/r\1/;s/-/./g' || echo "1.0.0"
}

package() {
  cd "$srcdir/${pkgname%-git}" 2>/dev/null || cd "$srcdir"
  install -Dm755 bin/arch-cleaner "$pkgdir/usr/bin/arch-cleaner"
}
