/// Oyunun dört ana karakteri ve duruma göre replikleri.
///
/// Metinler şu an Türkçe. İleride ikinci dil eklenirken bu dosyanın dile
/// karşılık gelen bir eşi yazılacak (bkz. `lib/data/game_content.dart`
/// içindeki kayıt tablosu); model yapısı aynı kaldığı için UI kodu
/// değişmeyecek.
library;

import '../models/character.dart';

/// Mert — Vizyoner CEO.
const Character kMert = Character(
  id: 'mert',
  name: 'Mert',
  title: 'Vizyoner CEO',
  personality:
      'Her hafta yeni bir "oyunun kurallarını değiştirecek" fikirle gelir. '
      'Teknik borcun ne olduğunu bilir, sadece önemsemez.',
  iconId: 'ceo',
  dialogues: {
    DialogueSituation.gameStart: [
      'Hoş geldin CTO! Pazara 6 ayda gireceğiz dedim yatırımcıya. Sen 3 ay duy.',
      'Ürün vizyonu hazır, sadece kodlanması kaldı. O da senin işin, değil mi?',
      'Rakipler uyuyor. Biz de uyumayacağız — özellikle sen.',
    ],
    DialogueSituation.highTechDebt: [
      'Teknik borç %60 mı? Borç iyidir, kaldıraç demektir. Yeni feature nerede?',
      'Zeynep yine panikliyor. Sen bana şu feature\'ı çıkar, borcu sonra konuşuruz.',
      'Sunucular yavaşsa daha büyük sunucu alırız. Kod neden yavaş olsun ki?',
    ],
    DialogueSituation.lowMorale: [
      'Ekip yorgun mu? Pizza söyledim. Motivasyon tamamdır.',
      'Ben de yorgunum ama vizyon yorulmuyor. Devam.',
      'İnsanlar maaş için değil, misyon için çalışır. Değil mi? ...Değil mi?',
    ],
    DialogueSituation.lowBudget: [
      'Kasada para mı kalmadı? Yeni tur açarız, değerleme yüksek görünsün yeter.',
      'Bütçe kısıtı yaratıcılığı artırır. Bunu bir konferansta duymuştum.',
      'Maaşları iki hafta erteleyebilir miyiz? Şaka. ...Yarı şaka.',
    ],
    DialogueSituation.goodWeek: [
      'İşte bu! Grafikler sağa yukarı gidiyor, sunumda tam da bunu istiyorum.',
      'Bu hafta harikaydı. Haftaya iki katını yapalım.',
      'Yatırımcıya "sürdürülebilir büyüme" dedim. Sürdürülebilir kısmı sende.',
    ],
    DialogueSituation.crisis: [
      'Panik yok! Panik varsa da bana söylemeyin, yatırımcı toplantısındayım.',
      'Bu bir kriz değil, bir "öğrenme fırsatı". Çözdükten sonra blog yazarız.',
      'Ne oldu? Önemli değil, çözülür. Sen çözersin. Ben inanıyorum sana.',
    ],
    DialogueSituation.victory: [
      '1 milyon dolar! Sana hep inandım. Şimdi B turu için 10 milyon lazım.',
      'Unicorn olduk! Bu hikâyeyi anlatırken senden "ekipten biri" diye bahsedeceğim.',
    ],
    DialogueSituation.defeat: [
      'Şirket battı ama vizyon yaşıyor. Yeni girişimimde CTO ister misin?',
      'Olmadı. Ama LinkedIn\'de "başarısızlıktan öğrendiklerim" diye bir post var sende.',
    ],
  },
);

/// Zeynep — Senior Backend Architect.
const Character kZeynep = Character(
  id: 'zeynep',
  name: 'Zeynep',
  title: 'Senior Backend Architect',
  personality:
      'Temiz kodun savunucusu. Teknik borç %60\'ı geçince kibarlığı bırakır. '
      'Haklı çıktığında bunu asla hatırlatmaz — sadece commit mesajına yazar.',
  iconId: 'architect',
  dialogues: {
    DialogueSituation.gameStart: [
      'Merhaba. Mimariyi baştan doğru kurarsak sonra ağlamayız. Baştan derken, şimdi.',
      'Test altyapısını ilk haftada kuralım. "Sonra yaparız" cümlesi hiç gerçekleşmedi.',
      'Kod tabanı şu an temiz. Bu cümleyi bir daha duyamayabilirsin, tadını çıkar.',
    ],
    DialogueSituation.highTechDebt: [
      'Teknik borç %60\'ı geçti. Bu artık borç değil, haciz.',
      'Bak, net konuşuyorum: bir sprint refactoring yapmazsak önümüzdeki ay hiçbir feature çıkmaz.',
      'Her yeni feature\'ı eski kodun üstüne koyuyoruz. Bu bir ürün değil, Jenga.',
      'Bu kod tabanına dokunmak için eldiven istiyorum. Üstelik ben yazdım bazılarını.',
    ],
    DialogueSituation.lowMorale: [
      'Ekip tükeniyor. İnsanlar kötü koddan değil, kötü kodu düzeltmeye izin verilmemesinden yoruluyor.',
      'Üç kişi bugün hiç konuşmadı. Bu normal değil, bu burnout.',
      'Pizza işe yaramıyor. Zaman işe yarıyor.',
    ],
    DialogueSituation.lowBudget: [
      'Bütçe kritik. En azından sunucu faturasını optimize edelim, orada yağ var.',
      'Para yoksa hız da olmaz. Bunu Mert\'e sen söyle, bana inanmıyor.',
    ],
    DialogueSituation.goodWeek: [
      'Bu hafta düzgün iş çıkardık. Testler yeşil, ben de mutluyum. İkisi aynı şey.',
      'Build 4 dakikaya indi. Küçük şeyler değil bunlar.',
      'Gördün mü? Düzgün yapınca daha hızlı oluyor. Garip ama matematik böyle.',
    ],
    DialogueSituation.crisis: [
      'Tamam, sakin. Logları açtım. Önce ne olduğunu anlayalım, sonra suçlu arayalım.',
      'Bunu geçen ay öngörmüştüm ama "backlog\'a alalım" dediniz. Neyse, çözelim.',
      'Rollback hazır. Ama rollback bir çözüm değil, zaman kazanmak.',
    ],
    DialogueSituation.victory: [
      'Unicorn olduk ve kod tabanı hâlâ ayakta. İkinciyi daha çok önemsiyorum.',
      'Başardık. Şimdi o TODO yorumlarını temizleyebilir miyim?',
    ],
    DialogueSituation.defeat: [
      'Üzgünüm. Ama şunu söyleyeyim: bu kod tabanı bizden önce öldü.',
      'Bitti. Yine de teşekkür ederim — en azından sonunda beni dinledin.',
    ],
  },
);

/// Can — Stajyer / Junior Developer.
const Character kCan = Character(
  id: 'can',
  name: 'Can',
  title: 'Stajyer / Junior Developer',
  personality:
      'Son derece hevesli, son derece tehlikeli. Öğrenme hızı yüksek, '
      'production\'a erişimi ise olmamalıydı.',
  iconId: 'junior',
  dialogues: {
    DialogueSituation.gameStart: [
      'Merhaba! İlk işim burası. Her şeyi öğrenmek istiyorum, özellikle production\'a nasıl girilir.',
      'README\'yi okudum, hiçbir şey anlamadım ama çok heyecanlıyım!',
      'Bir sorum var: "geçici çözüm" ne kadar geçici oluyor genelde?',
    ],
    DialogueSituation.highTechDebt: [
      'Bu dosya 4000 satır. Normal mi? Ben normal sandım, ona göre bir şey ekledim.',
      'Teknik borcu azaltmak için bir script yazdım. Çalıştırmadım. Siz karar verin.',
      'Şu fonksiyonun ne yaptığını anlamadım ama silince testler geçti. Sildim.',
    ],
    DialogueSituation.lowMorale: [
      'Herkes çok sessiz. Ben bir şey mi yaptım? Genelde ben bir şey yapmış oluyorum.',
      'Moral düşükse ben müzik açabilirim. Hoparlörden. Ofiste.',
      'Zeynep bugün bana hiç kızmadı. Endişelendim.',
    ],
    DialogueSituation.lowBudget: [
      'Staj ücretimi almasam olur mu? Yani... alsam daha iyi ama anlıyorum.',
      'AWS faturasını gördüm. O test ortamını kapatmam gerekiyordu, değil mi?',
    ],
    DialogueSituation.goodWeek: [
      'İlk pull request\'im merge oldu! Sadece bir satır ama o satır benim.',
      'Bu hafta hiçbir şeyi bozmadım. Gurur duyuyorum.',
      'Code review\'da 12 yorum aldım ama hepsini anladım! Çoğunu.',
    ],
    DialogueSituation.crisis: [
      'Bir şey oldu. Benimle ilgili olabilir. Yüksek ihtimalle benimle ilgili.',
      'Panikliyorum ama profesyonelce panikliyorum.',
      'Terminalde bir şey yazıyordu, kapattım. Önemli miydi?',
    ],
    DialogueSituation.victory: [
      'Unicorn mu olduk? Yani CV\'me "unicorn\'da çalıştım" yazabilir miyim?',
      'Başardık! Ben de buradaydım! Bazen yardım bile ettim!',
    ],
    DialogueSituation.defeat: [
      'Benim yüzünden mi? Dürüst ol. ...Tamam, bilmek istemiyorum.',
      'Çok şey öğrendim. Çoğunu yapmamam gerekenlerden öğrendim.',
    ],
  },
);

/// Elif — QA & DevOps Uzmanı.
const Character kElif = Character(
  id: 'elif',
  name: 'Elif',
  title: 'QA & DevOps Uzmanı',
  personality:
      'Test kapsamını, pipeline\'ı ve sunucu sağlığını bir ebeveyn gibi takip eder. '
      'En sevdiği cümle: "benim makinemde çalışıyor" cümlesini duymamak.',
  iconId: 'devops',
  dialogues: {
    DialogueSituation.gameStart: [
      'Pipeline\'ı kurdum. Artık bozulan şeyi merge\'den önce öğreniyoruz, sonra değil.',
      'Selam. Monitoring açık, alarmlar telefonumda. Yani uykum senin kararlarına bağlı.',
      'Test kapsamı %34. Bunu yükselteceğiz, söz verdim kendime.',
    ],
    DialogueSituation.highTechDebt: [
      'Build süresi 22 dakikaya çıktı. Deploy etmek artık bir öğle arası aktivitesi.',
      'Teknik borç arttıkça flaky test sayısı artıyor. Artık testlere de güvenmiyorum.',
      'Son 5 deploy\'un 3\'ü rollback ile bitti. İstatistik konuşuyor, ben susuyorum.',
    ],
    DialogueSituation.lowMorale: [
      'Gece 2\'de alarm çaldığında kimse kalkmak istemiyor. Haklılar.',
      'On-call rotasyonu bir kişiye indi. O kişi de benim.',
      'İnsanlar yorgunken daha çok hata yapıyor, hata olunca daha çok yoruluyor. Döngü bu.',
    ],
    DialogueSituation.lowBudget: [
      'Sunucu maliyetini %30 kısabilirim ama o zaman trafiği kaldırmayız. Seçim senin.',
      'Staging ortamını kapatalım mı? Kapatırsak production\'ı canlı test ederiz. Şaka değil, uyarı.',
    ],
    DialogueSituation.goodWeek: [
      'Uptime %99.9. Bu hafta telefonum hiç çalmadı, bayram ettim.',
      'Test kapsamı yükseldi, deploy süresi düştü. Bana bunu her hafta yaşatın.',
      'Sıfır incident. Bu cümleyi yazarken bile tahtaya vuruyorum.',
    ],
    DialogueSituation.crisis: [
      'Alarm çalıyor. Grafiklere bakıyorum. İyi haber yok.',
      'Incident kanalını açtım. Herkes sakin kalsın, ben zaten yeterince gerginim.',
      'Monitoring her şeyi gördü, kimse monitoring\'e bakmadı. Klasik.',
    ],
    DialogueSituation.victory: [
      'Unicorn olduk ve production ayakta. İkisini birlikte başarmak nadirdir.',
      'Kazandık. Şimdi şu disaster recovery planını gerçekten yazalım mı?',
    ],
    DialogueSituation.defeat: [
      'Sunucular sustu. Son log satırını çerçeveletip asacağım.',
      'Bitti. Ben yine de post-mortem yazacağım. Kimse okumayacak ama yazacağım.',
    ],
  },
);

/// Bütün karakterler.
const List<Character> kCharacters = [kMert, kZeynep, kCan, kElif];

/// Kimlikten karakter bulur; bulunamazsa `null` döner.
Character? characterById(String id) {
  for (final character in kCharacters) {
    if (character.id == id) return character;
  }
  return null;
}
