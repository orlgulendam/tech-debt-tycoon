# Tech Debt Tycoon

Bir yazılım girişiminin CTO'su olma simülasyonu. Haftalık (sprint) kararlar
alırsın: hızlı feature mi çıkarırsın, yoksa teknik borcu mu ödersin? Şirket
değerlemesini **1.000.000$**'a çıkarırsan Unicorn olursun.

Kaybetme yolları:

| Durum | Sonuç |
| --- | --- |
| Bütçe 0$ | İflas |
| Teknik borç %100 | Sunucular yandı |
| Ekip morali %0 | Toplu istifa |

Flutter ile yazıldı, tamamen çevrimdışı çalışır, dikey (portrait) modda tek
elle oynanır.

## Durum

Geliştirme aşamalı yürüyor:

- [x] **Aşama 1** — İskelet, bağımlılıklar, veri modelleri ve statik veri
- [x] **Aşama 2** — Oyun motoru, Riverpod durum yönetimi, ipucu algoritması, otomatik kayıt, sahte reklam
- [x] **Aşama 3** — Tema, navigasyon, ekranlar, onboarding, bottom sheet bileşenleri
- [ ] **Aşama 4** — Haptic feedback, skor kartı, mağaza yayın hazırlığı

## Geliştirme ortamı kurulumu

Projeyi derlemek için Flutter SDK gerekiyor. Temiz bir makinede tek komut:

```bash
bash tool/setup_flutter.sh
```

Betik Flutter SDK'yi (stable) `~/flutter` altına kurar, telemetriyi kapatır ve
`flutter pub get` çalıştırır. İki kez koşturmak güvenlidir — SDK kuruluysa
indirme adımını atlar.

Sonrasında PATH'i kabuğuna ekle:

```bash
export PATH="$HOME/flutter/bin:$PATH"
```

SDK'nın kurulacağı yeri veya kanalı değiştirmek istersen:

```bash
FLUTTER_HOME=/opt/flutter FLUTTER_CHANNEL=beta bash tool/setup_flutter.sh
```

### Doğrulama

```bash
flutter analyze
```

```bash
dart test
```

```bash
flutter test
```

Testler iki gruba ayrılıyor:

| Komut | Kapsam | Adet |
| --- | --- | --- |
| `dart test` | Saf Dart: modeller, statik veri, oyun motoru, ipucu algoritması, kayıt servisi, Riverpod provider'ları | 217 |
| `flutter test` | Yukarıdakilerin hepsi + widget testleri | 237 |

Model, motor, servis ve **provider** katmanlarının hiçbiri Flutter'a bağımlı
değil, bu yüzden oyunun bütün mantığı motor başlatılmadan koşuyor — CI'da
belirgin biçimde hızlı. Hangi dosyanın hangi koşucuya gittiği
`dart_test.yaml` içinde yazılı.

> **Not:** Betik Android SDK ve Java kurmaz, dolayısıyla APK/AAB derlemez.
> Analiz ve testler için gerek yok; cihaz derlemesi yapacaksan Android Studio
> ya da `sdkmanager` ile Android SDK'yi ayrıca kurman gerekir.

## Proje yapısı

```
lib/
├── models/      # Değişmez veri sınıfları (saf Dart, Flutter bağımlılığı yok)
├── data/        # Statik oyun içeriği: karakterler, aksiyonlar, olaylar, sözlük
├── providers/   # Riverpod provider'ları (saf Dart)
├── services/    # Oyun motoru, kayıt, ipucu, reklam servisleri
├── theme/       # Renkler, tipografi, ikon eşlemesi
├── screens/     # Ofis, Ekip, Sözlük, Log, onboarding, kabuk
├── widgets/     # Yeniden kullanılabilir bileşenler + bottom sheet'ler
├── l10n/        # Merkezi metin yönetimi
└── main.dart
test/
├── models_test.dart           # copyWith, serileştirme, türetilmiş değerler
├── data_integrity_test.dart   # statik verinin eksiksizliği ve denge aralıkları
├── l10n_test.dart             # her metin anahtarının karşılığı dolu mu
├── game_engine_test.dart      # haftalık simülasyon, olaylar, kazanma/kaybetme
├── hint_service_test.dart     # ipucu kurallarının öncelik sırası
├── storage_service_test.dart  # kayıt sözleşmesi
├── ad_service_test.dart       # sahte reklam sonuçları
├── game_provider_test.dart    # otomatik kayıt, devam ettirme, oyun akışı
└── widget/
    └── app_smoke_test.dart    # uygulama gerçekten ayağa kalkıyor mu
tool/
├── setup_flutter.sh
└── balance_sim.dart           # oyun dengesi simülatörü (ölçüm aracı)
assets/
└── fonts/                     # JetBrains Mono (gömülü, çevrimdışı)
```

### Mimari kararlar

- **Durum yönetimi:** Riverpod. `lib/providers/` bilinçli olarak **saf Dart**
  `riverpod` paketini kullanıyor; `flutter_riverpod`'a yalnızca widget'lar
  dokunuyor. Böylece bütün oyun mantığı `dart test` ile test edilebiliyor.
- **Oyun motoru:** `lib/services/game_engine.dart` tamamen saf
  fonksiyonlardan oluşuyor — içeride durum tutmuyor, rastgeleliği çağırandan
  alıyor. Bu yüzden her kural deterministik biçimde test edilebiliyor
  (200 haftalık rastgele oyun testi dahil).
- **Otomatik kayıt:** Durum her değiştiğinde kaydedilir. Karar bekleyen olay
  kartı da kayda yazıldığı için oyuncu uygulamayı olay ekranında kapatsa bile
  açtığında aynı kararla karşılaşır.
- **Kalıcı kayıt:** Hive. Kayıtlı modeller (`GameState`, `GameRecord`) Hive
  kutusunda **JSON map** olarak tutulur, üretilmiş `TypeAdapter` ile değil.
  Gerekçesi `pubspec.yaml` içinde yazılı: `hive_generator` araç zincirini
  (analyzer, build_runner) iki ana sürüm geriye çiviliyor ve bu kadar küçük
  bir kayıt yükü için ikili formatın kazancı ölçülemeyecek kadar az.
- **Metinler:** Kullanıcıya görünen hiçbir metin widget'ın içine gömülmez.
  Hepsi `lib/l10n/` altındaki `StringKey` → metin tablosundan okunur; karakter
  replikleri ve olay kartları ise `lib/data/` altında, dile göre
  değiştirilebilecek biçimde durur (`GameContent` kayıt tablosu). İlk sürüm
  Türkçe; ikinci dil için yalnızca yeni bir metin tablosu ve içerik dosyası
  eklenir, UI kodu değişmez.

## Oyun dengesi

Denge sayıları tahminle değil **ölçümle** ayarlandı. `tool/balance_sim.dart`
birkaç oyuncu stratejisiyle binlerce oyun koşturup kazanma oranını, oyun
uzunluğunu ve kaybetme nedenlerini raporluyor:

```bash
dart run tool/balance_sim.dart 3000
```

Mevcut ayarlarla ölçülen sonuç (3000 oyun/strateji):

| Strateji | Kazanma | Medyan hafta | Kaybetme nedenleri |
| --- | --- | --- | --- |
| Sadece feature çıkar | %0 | – | borç %100 |
| Dengeli oyun | %99,8 | 27 | – |
| İpucunu dinle | %97,9 | 27 | borç %2 |
| Rastgele | %55,7 | 35 | borç %42, iflas %3 |

Tasarım hedefi: teknik borcu yok sayan oyuncu **her zaman** kaybetsin,
bilinçli oyuncu 25-40 haftada kazansın. İlerlemenin ana motoru tek tek
aksiyonlar değil **gelir**: değerleme her hafta gelirin bir katı kadar
büyüyor ve bu büyüme teknik borç ile moral çarpanlarıyla ölçekleniyor —
yani dört kaynak birbirine bağlı.

Bütün ayar düğmeleri tek dosyada: `lib/data/game_balance.dart`.

## İçerik

| Veri | Adet |
| --- | --- |
| Ana karakter | 4 (Mert, Zeynep, Can, Elif) |
| Karakter repliği | 86 (4 karakter × 8 durum) |
| Haftalık aksiyon | 5 |
| İşe alım seçeneği | 4 (Junior, Mid, Senior, DevOps) |
| Olay kartı | 14 (41 seçenek) |
| Sözlük terimi | 17 |
| Metin anahtarı | 136 |
