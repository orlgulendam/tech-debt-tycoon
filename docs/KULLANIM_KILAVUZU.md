# Tech Debt Tycoon — Kullanım Kılavuzu

Bir yazılım girişiminin CTO'susun. Her hafta tek bir karar veriyorsun ve
o kararın bedelini sen ödüyorsun. Hedef: şirket değerlemesini
**1.000.000$**'a çıkarmak.

---

## 1. Oyunun amacı

| | |
| --- | --- |
| **Kazanma** | Değerleme 1.000.000$'a ulaşır (Unicorn 🦄) |
| **Süre** | Dengeli oynarsan ortalama **27 hafta** |
| **Kaybetme** | Üç yoldan biri (aşağıda) |

Oyun tamamen çevrimdışı çalışır, internet istemez ve ilerlemeni
otomatik kaydeder. Uygulamayı kapatıp açtığında kaldığın haftadan devam
edersin — hatta bir olay kartı ekranındayken kapatsan bile aynı kararla
karşılaşırsın.

---

## 2. Beş kaynak

Ekranın üstündeki panelde her zaman beş sayı var. Oyun bu beşinin
birbirine bağlı olması üzerine kurulu.

### 💰 Bütçe
Kasandaki nakit. Her hafta gelir girer, maaşlar çıkar.
**0$'a düşerse iflas edersin.**

### 📈 Değerleme
Şirketin değeri. Kazanmak için 1.000.000$ olmalı.
**Ana büyüme kaynağı tek tek aksiyonlar değil, gelirin kendisidir.**
Her hafta değerleme, haftalık gelirinin bir katı kadar büyür — ama bu
büyüme teknik borç ve moral tarafından kısılır.

### 💵 Haftalık Gelir
Ürünün her hafta kazandırdığı para. Aksiyonlarla ve işe alımlarla
büyür. Değerleme büyümesinin motorudur: **geliri büyütmek, değerlemeyi
büyütmenin en sağlam yoludur.**

### ⚠️ Teknik Borç (%0–100)
Kod kalitesi açığı. Üç şekilde zarar verir:

- **%60 üstünde** gelirinin bir kısmını yemeye başlar ve ekip her hafta
  moral kaybeder.
- **%80 üstünde** moral kaybı ikiye katlanır.
- **%100'e ulaşırsa sunucular yanar ve oyun biter.**

Ve en önemlisi: **hiçbir şey yapmasan bile her hafta kendiliğinden
artar.** Başta haftada 3 puan, oyun ilerledikçe 8 puana kadar çıkar —
kod tabanı büyüdükçe aynı özen daha az yetiyor.

### ❤️ Ekip Morali (%0–100)
Ekibin hâli. Bir ölüm koşulundan çok bir **verimlilik vergisi**:

- **%70 altında** hem nakit girişin hem değerleme büyümen azalmaya
  başlar. %0'da üretkenlik 0,55 katına iner.
- **%0'a düşerse ekip toplu istifa eder ve oyun biter.**

> **Net Nakit Akışı** satırı en çok gözden kaçan sayıdır: gelir eksi
> maaşlar. Negatifse her hafta para kaybediyorsun demektir.

---

## 3. Haftalık aksiyonlar

Her hafta **tek bir** aksiyon seçersin. Kartların üstünde etkileri
yazılıdır — oyun sürpriz ceza üzerine değil, bilinçli ödün verme
üzerine kuruludur.

| Aksiyon | Ne yapar | Bedeli |
| --- | --- | --- |
| 🚀 **Hızlı Feature Çıkar** | En yüksek gelir ve değerleme sıçraması | `+%15` teknik borç, `-%6` moral |
| ✅ **Temiz Kod & Test Yaz** | Dengeli gelir, borç üretmez | Daha az gelir |
| 🔧 **Refactoring Sprinti** | `-%25` teknik borç, `+%8` moral | O hafta kayda değer gelir yok |
| ❤️ **Ekip Motivasyonu** | `+%20` moral | `-3.000$` bütçe |
| 👤 **İşe Alım** | Ekibe kalıcı biri katılır | Tek seferlik ücret + haftalık maaş |

**Altın kural:** Sadece "Hızlı Feature Çıkar" oynayan oyuncu **her zaman**
kaybeder. Simülasyonda bu stratejinin kazanma oranı %0'dır — teknik borç
her seferinde sunucuları yakar.

---

## 4. İşe alım

Dört aday var. Her birinin haftalık maaşı, gelir katkısı ve **pasif
teknik borç etkisi** farklı.

| Aday | Maaş/hafta | Gelir/hafta | Teknik borç | Moral |
| --- | --- | --- | --- | --- |
| **Junior Developer** | 800$ | +450$ | `+%3` | `+%1` |
| **Mid-level Developer** | 1.500$ | +1.100$ | `%0` | `%0` |
| **Senior Developer** | 2.600$ | +2.000$ | `-%2` | `+%2` |
| **DevOps Engineer** | 2.300$ | +1.400$ | `-%4` | `+%1` |

İşe alımın tek seferlik maliyeti **iki haftalık maaştır** (ilan,
görüşme, ekipman).

Dikkat: Junior ucuzdur ama **teknik borç üretir**. Senior ve DevOps
pahalıdır ama borcu **eritirler** — yani kendilerini amorti edebilirler.
Ekip sayfasındaki "Haftalık net" satırı her çalışanın gerçek bilançosunu
gösterir.

---

## 5. Olay kartları

Hafta kapandığında bir olay çıkabilir (ilk hafta hariç). Teknik borcun
yüksekse olay çıkma ihtimali artar — borçlu kod daha çok sürpriz üretir.

Her kartın 2–3 seçeneği vardır ve **her seçeneğin bedeli önceden
görünür**. Bedava doğru cevap yoktur.

Bazı seçenekler krizi "çözmüş" sayılır ve skoruna **çözülen kriz** olarak
yazılır. Genelde bunlar kısa vadede daha pahalı, uzun vadede daha ucuz
olanlardır.

Örnek: *Cuma 17:55'te deploy baskısı.* Hemen çıkarsan gelir ve değerleme
kazanırsın ama teknik borç ve moral bedelini ödersin. Pazartesiye
ertelersen daha az kazanır, krizi çözmüş olursun.

---

## 6. Danışman (ipucu sistemi)

Ofis ekranındaki **Danışman** satırına dokunursan o anki durumunun en
kritik sorununu ve ne yapman gerektiğini söyler.

- Her oyunda **3 ücretsiz ipucu** hakkın var.
- Hak, paneli açtığında değil **"Danışmana sor"a bastığında** harcanır —
  yanlışlıkla açıp kapatmak hak yakmaz.
- Haklar bitince reklam izleyip danışman tutabilirsin (her reklam +1 hak).
- Danışmanın önerdiği aksiyon kartı ofis ekranında yeşil çerçeveyle
  **vurgulanır**.

Danışman tek bir şey söyler, liste vermez: en acil olan ne ise onu.

---

## 7. Ekranlar

### 🖥 Ofis
Ana ekran. Metrikler, duruma göre konuşan karakterler, danışman ve
haftalık aksiyonlar. Okunacak şeyler üstte, dokunulacak şeyler altta —
tek elle oynanabilsin diye.

### 👥 Ekip
Kadron, herkesin net katkısı ve işe alım. Ekibin toplam pasif borç/moral
etkisini de burada görürsün.

### 📖 Sözlük
17 yazılım terimi. Her birinde üç parça var: **nedir**, **gerçek hayatta
neye benzer** ve **oyunda hangi sayıya dokunur**. Arama Türkçe karaktere
duyarsızdır — "borc" yazarsan "borç" içerenleri bulur.

### 🕘 Log & Kariyer
Geçmiş oyunların, en yüksek değerlemen, Unicorn sayın ve her oyunun
sonundaki CTO notu.

---

## 8. Karakterler

| | |
| --- | --- |
| **Mert** — Vizyoner CEO | Hızlı büyüme baskısı yapar. Teknik borcun ne olduğunu bilir, sadece önemsemez. |
| **Zeynep** — Senior Backend Architect | Temiz kod savunucusu. Teknik borç %60'ı geçince kibarlığı bırakır. |
| **Can** — Stajyer / Junior | Son derece hevesli, son derece tehlikeli. Production'a erişimi olmamalıydı. |
| **Elif** — QA & DevOps | Test kapsamını, pipeline'ı ve sunucu sağlığını bir ebeveyn gibi takip eder. |

Kim konuşacağı duruma göre seçilir: borç yüksekse Zeynep, moral düşükse
Elif, bütçe kritikse Mert.

---

## 9. Kazanmak için strateji

1. **Erken işe al.** Tek başına 1.000.000$'a çıkamazsın. Bütçen uygunsa
   ilk haftalarda birini al; gelir katkısı erken başlasın.
2. **Geliri büyüt.** Değerleme gelirden besleniyor. Erken gelir artışı
   sonraki her haftaya faiz gibi işler.
3. **Teknik borcu %60'ın altında tut.** Bu eşiği geçince gelirin kesilir
   ve moral erimeye başlar. İki "Hızlı Feature" sonrası bir
   "Refactoring Sprinti" iyi bir ritimdir.
4. **Morali %70'in üstünde tut.** Altına inince her şey yavaşlar.
5. **Net nakit akışına bak.** Negatifse bordro seni yiyor demektir.
6. **Oyalanma.** Teknik borcun doğal artışı zamanla hızlanır; uzayan
   oyun giderek zorlaşır.

> Ölçüm sonucu: dengeli oynayan oyuncuların **%99'u** kazanıyor,
> rastgele oynayanların **%56'sı**, sadece feature çıkaranların **%0'ı**.

---

## 10. Oyun sonu

Oyun bittiğinde bir **CTO Karnesi** çıkar: kaç hafta dayandığın, final
değerlemen, çözdüğün kriz sayısı ve son teknik borç/moral durumun.
Karneyi görsel olarak paylaşabilirsin.

Her tamamlanan oyun "Log & Kariyer" sekmesine kaydedilir. Yarıda
bıraktığın oyun kaydedilmez — yarıda bırakılan oyun bir sonuç değildir.

---

## 11. Sık sorulanlar

**İnternet gerekiyor mu?**
Hayır. Oyun tamamen çevrimdışı çalışır. Reklamlar bile sahtedir.

**İlerlemem kaybolur mu?**
Hayır, her karardan sonra otomatik kaydedilir.

**Yeni oyuna nasıl başlarım?**
Sağ üstteki yenile simgesi. Onay ister, çünkü devam eden oyun silinir.

**Animasyonlar rahatsız ediyor.**
Telefonunun erişilebilirlik ayarlarından "hareketi azalt" seçeneğini
açarsan oyundaki bütün animasyonlar kapanır.

**Oyun çok kolay/zor.**
Denge `lib/data/game_balance.dart` dosyasındaki tek bir sınıfta toplanmış
durumda; `dart run tool/balance_sim.dart` ile değişikliğin etkisini
ölçebilirsin.
