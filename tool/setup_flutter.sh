#!/usr/bin/env bash
#
# Tech Debt Tycoon - geliştirme ortamı kurulumu.
#
# Flutter SDK'yi kurar (yoksa), PATH'e ekler ve proje bağımlılıklarını indirir.
# Temiz bir bulut oturumunda ya da yeni bir makinede tek komutla çalışabilir
# olması için yazıldı; iki kez koşturmak güvenlidir (idempotent).
#
# Kullanim:
#   bash tool/setup_flutter.sh          # kur ve bağımlılıkları indir
#   source tool/setup_flutter.sh        # ayrıca PATH'i mevcut kabuğa aktar
#
# Not: Android SDK ve Java kurmaz, dolayısıyla APK/AAB derlemez.
# `flutter analyze`, `flutter test` ve `dart test` için bu kadarı yeterli.

set -euo pipefail

FLUTTER_CHANNEL="${FLUTTER_CHANNEL:-stable}"
FLUTTER_HOME="${FLUTTER_HOME:-$HOME/flutter}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

log() { printf '\n==> %s\n' "$1"; }

# 1) SDK ------------------------------------------------------------------
if [ -x "$FLUTTER_HOME/bin/flutter" ]; then
  log "Flutter SDK zaten kurulu: $FLUTTER_HOME"
else
  log "Flutter SDK indiriliyor ($FLUTTER_CHANNEL) -> $FLUTTER_HOME"
  git clone --depth 1 -b "$FLUTTER_CHANNEL" \
    https://github.com/flutter/flutter.git "$FLUTTER_HOME"
fi

export PATH="$FLUTTER_HOME/bin:$PATH"

# 2) İlk çalıştırma: Dart SDK ve araç zincirini indirir ------------------
log "Sürüm bilgisi (ilk çalıştırmada Dart SDK indirilir, biraz sürer)"
flutter --version

# Telemetriyi kapat (hata verirse kurulumu durdurmasın).
flutter config --no-analytics >/dev/null 2>&1 || true

# 3) Proje bağımlılıkları ------------------------------------------------
log "Bağımlılıklar indiriliyor (flutter pub get)"
cd "$REPO_ROOT"
flutter pub get

# 4) Doğrulama -----------------------------------------------------------
log "Kurulum tamam. Doğrulamak için:"
cat <<'EOF'
  export PATH="$HOME/flutter/bin:$PATH"

  flutter analyze     # statik analiz
  dart test           # testler (saf Dart, hızlı)
  flutter test        # testler (Flutter koşucusu)
EOF
