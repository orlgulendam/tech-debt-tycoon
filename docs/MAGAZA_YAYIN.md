# Mağaza Yayın Hazırlığı

Google Play ve App Store'a çıkmak için gereken adımlar ve bu depoda
hazır olan/olmayan şeyler.

---

## Durum özeti

| Konu | Durum |
| --- | --- |
| Uygulama kimliği | ✅ `com.orlgulendam.tech_debt_tycoon` |
| Görünen ad | ✅ "Tech Debt Tycoon" (Android + iOS) |
| Uygulama ikonu | ✅ Üretildi (`tool/make_icon.py`) |
| Dikey mod kilidi | ✅ Kodda + her iki platform manifestinde |
| Sürüm | ✅ `pubspec.yaml` → `1.0.0+1` |
| Android imzalama | ⚙️ Yapılandırma hazır, **anahtar sende** |
| Kod küçültme (R8) | ✅ Yayın derlemesinde açık |
| İzinler | ✅ Hiçbir çalışma zamanı izni istenmiyor |
| Gizlilik politikası | ✅ `docs/GIZLILIK.md` (yayınlanması gerek) |
| Mağaza metinleri | ✅ `docs/MAGAZA_METINLERI.md` |
| Ekran görüntüleri | ❌ Cihazda/emülatörde alınmalı |
| Yaş derecelendirme | ❌ Mağaza formları doldurulmalı |

---

## 1. Android imzalama anahtarı

Yayın derlemesi `android/key.properties` dosyasını arar. Dosya yoksa
debug anahtarıyla imzalar (geliştirmede `flutter run --release`
çalışsın diye) — **bu hâliyle mağazaya yüklenemez.**

Anahtar üret:

```bash
keytool -genkey -v -keystore ~/tech-debt-tycoon-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias release
```

Sonra `android/key.properties` oluştur:

```properties
storePassword=<parola>
keyPassword=<parola>
keyAlias=release
storeFile=/mutlak/yol/tech-debt-tycoon-release.jks
```

> ⚠️ Bu dosya ve `.jks` uzantılı anahtarlar `.gitignore`'da — **asla
> depoya girmemeli.** Anahtarı kaybedersen aynı uygulamayı bir daha
> güncelleyemezsin; yedeğini güvenli bir yerde tut.

Derleme:

```bash
flutter build appbundle --release
```

Çıktı: `build/app/outputs/bundle/release/app-release.aab`

---

## 2. iOS

Xcode gerekir (bu depodan yapılandırılamaz):

1. `ios/Runner.xcworkspace` dosyasını Xcode'da aç.
2. **Signing & Capabilities** → Team seç, otomatik imzalamayı aç.
3. Bundle identifier'ın `com.orlgulendam.tech_debt_tycoon` olduğunu doğrula.

```bash
flutter build ipa --release
```

---

## 3. Uygulama ikonu

İkon koda gömülü bir çizim; renk ya da biçim değişirse tek komutla
yeniden üretilir:

```bash
python3 tool/make_icon.py
```

Betik Android mipmap klasörlerini, iOS `AppIcon.appiconset` dosyalarını
ve mağaza listelemesi için `assets/icon/icon-1024.png` görselini yazar.
iOS ikonları saydam kanal içermez (App Store kabul etmiyor).

---

## 4. Ekran görüntüleri

Her iki mağaza da gerçek cihaz/emülatör görüntüsü istiyor. Önerilen
sahneler:

1. Ofis ekranı — metrikler ve aksiyon kartları
2. Bir kriz olay kartı (ör. "Force Push" ya da production veritabanı)
3. Hafta kapanış özeti
4. Sözlük ekranı
5. Kazanılan oyunun CTO karnesi

```bash
flutter run --release
```

Gerekli boyutlar: Google Play en az 2 görsel (1080×1920 uygun),
App Store 6,7" ve 6,5" iPhone için ayrı setler.

---

## 5. Gizlilik ve veri

Oyun **hiçbir veri toplamıyor**:

- Ağ bağlantısı yok; tamamen çevrimdışı çalışıyor.
- Analitik, çökme raporlama ya da reklam SDK'sı yok.
- Reklamlar sahte (oyun içi mekanik), gerçek bir reklam ağı bağlı değil.
- Bütün kayıtlar cihazda, Hive kutusunda duruyor.
- Çalışma zamanı izni istenmiyor.

Her iki mağazanın veri güvenliği formunda **"veri toplanmıyor"**
işaretlenmeli. Gizlilik politikası metni `docs/GIZLILIK.md` içinde;
mağazalar bir **URL** istediği için bunun bir yerde yayınlanması gerek
(GitHub Pages yeterli).

> Not: İleride gerçek bir reklam ağı bağlanırsa bu bölüm ve gizlilik
> politikası **mutlaka** güncellenmeli — reklam SDK'ları reklam kimliği
> toplar.

---

## 6. Yayın öncesi kontrol listesi

```bash
flutter analyze
```

```bash
flutter test
```

```bash
flutter build appbundle --release
```

- [ ] `android/key.properties` hazır ve anahtar yedeklendi
- [ ] `pubspec.yaml` içindeki sürüm artırıldı (`1.0.0+1` → `1.0.1+2`)
- [ ] Ekran görüntüleri alındı
- [ ] Gizlilik politikası bir URL'de yayınlandı
- [ ] Mağaza metinleri girildi (`docs/MAGAZA_METINLERI.md`)
- [ ] Veri güvenliği formu "veri toplanmıyor" olarak dolduruldu
- [ ] İçerik derecelendirme anketi tamamlandı
