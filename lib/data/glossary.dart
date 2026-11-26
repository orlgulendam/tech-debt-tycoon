/// Oyun içi yazılım terimleri sözlüğü.
///
/// Her terimde üç parça var: kısa tanım, gerçek hayattan örnek ve oyundaki
/// mekanik karşılığı. Üçüncüsü önemli — oyuncu terimi öğrenirken aynı anda
/// oyunun hangi sayısına dokunduğunu da görüyor.
library;

import '../models/glossary_term.dart';

/// Sözlükteki bütün terimler.
const List<GlossaryTerm> kGlossaryTerms = [
  GlossaryTerm(
    id: 'technical_debt',
    name: 'Technical Debt',
    shortDefinition:
        'Hızlı gitmek için bilinçli ya da bilinçsizce bırakılan kod kalitesi açığı. '
        'Tıpkı para borcu gibi faiz işler.',
    realLifeExample:
        'Demoyu yetiştirmek için kopyala-yapıştır yazdığın o modül, altı ay sonra '
        'her küçük değişiklikte üç yeri birden bozuyor.',
    gameEffect:
        'Teknik Borç metriğidir. %60\'ı geçince gelir artışı yavaşlar ve olay '
        'kartları sertleşir; %100\'e ulaşırsa sunucular yanar ve oyun biter.',
    category: GlossaryCategory.engineering,
  ),
  GlossaryTerm(
    id: 'refactoring',
    name: 'Refactoring',
    shortDefinition:
        'Davranışı değiştirmeden kodun iç yapısını iyileştirmek. Dışarıdan '
        'hiçbir şey olmamış gibi görünür.',
    realLifeExample:
        '4000 satırlık dosyayı sekiz anlamlı parçaya bölmek. Ürün aynı çalışır '
        'ama artık yeni geliştirici bir haftada değil bir günde anlıyor.',
    gameEffect:
        '"Refactoring Sprinti" aksiyonu teknik borcu %25 düşürür ve morali %8 '
        'artırır; karşılığında o hafta kayda değer gelir gelmez.',
    category: GlossaryCategory.engineering,
  ),
  GlossaryTerm(
    id: 'sprint',
    name: 'Sprint',
    shortDefinition:
        'Belirli bir işi bitirmeye ayrılmış kısa, sabit süreli çalışma dilimi. '
        'Genelde 1-2 hafta.',
    realLifeExample:
        'Pazartesi "bu sprint şunları yapacağız" denir, cuma yarısının '
        'yapıldığı keşfedilir, kalanı sonraki sprint\'e devredilir.',
    gameEffect:
        'Oyundaki bir hafta bir sprint\'tir. Her sprint\'te tek bir aksiyon '
        'seçersin; sprint kapanınca gelir, maaşlar ve pasif etkiler işlenir.',
    category: GlossaryCategory.process,
  ),
  GlossaryTerm(
    id: 'production',
    name: 'Production',
    shortDefinition:
        'Gerçek kullanıcıların kullandığı canlı ortam. Burada yapılan hata '
        'gerçek paraya ve gerçek öfkeye dönüşür.',
    realLifeExample:
        '"Benim makinemde çalışıyordu" cümlesinin anlamını yitirdiği yer. '
        'Test ortamı affeder, production affetmez.',
    gameEffect:
        'Olay kartlarının çoğu production\'da geçer. Teknik borç yüksekken '
        'production kaynaklı kriz kartlarının etkisi daha ağır olur.',
    category: GlossaryCategory.infrastructure,
  ),
  GlossaryTerm(
    id: 'deploy',
    name: 'Deploy',
    shortDefinition:
        'Yazılan kodu kullanıcıların erişebileceği ortama taşıma işlemi.',
    realLifeExample:
        'Cuma 17:55\'te yapılan deploy, hafta sonu planlarının en büyük '
        'düşmanıdır. Deneyimli ekipler cuma deploy etmez.',
    gameEffect:
        'Bazı olay kartları deploy kararı sorar. Acele deploy gelir ve '
        'değerleme getirebilir ama teknik borç ve kriz riskini artırır.',
    category: GlossaryCategory.infrastructure,
  ),
  GlossaryTerm(
    id: 'ci_cd',
    name: 'CI/CD',
    shortDefinition:
        'Continuous Integration / Continuous Delivery: kodun otomatik test '
        'edilip otomatik yayınlanmasını sağlayan boru hattı.',
    realLifeExample:
        'Pull request açtığın anda testler kendiliğinden koşar. Bozuksa '
        'merge edemezsin — yani seni kendinden korur.',
    gameEffect:
        'DevOps çalışanı işe almak CI/CD kurar sayılır: her hafta teknik borcu '
        '%4 eritir ve deploy kaynaklı olayların olumsuz etkisini azaltır.',
    category: GlossaryCategory.infrastructure,
  ),
  GlossaryTerm(
    id: 'pull_request',
    name: 'Pull Request',
    shortDefinition:
        'Yazdığın değişikliğin ana koda katılmadan önce incelenmesi için '
        'açılan talep. Kısaca PR.',
    realLifeExample:
        '"LGTM" yazıp 800 satırı onaylamak yerine gerçekten okumak, '
        'gelecekteki üç gecelik bug avını önler.',
    gameEffect:
        '"Temiz Kod & Test Yaz" aksiyonu düzgün PR sürecini temsil eder: '
        'teknik borç artmaz, moral %2 yükselir.',
    category: GlossaryCategory.process,
  ),
  GlossaryTerm(
    id: 'unit_test',
    name: 'Unit Test',
    shortDefinition:
        'Kodun en küçük parçasını tek başına doğrulayan otomatik test.',
    realLifeExample:
        'Bir fonksiyonun sıfıra bölme durumunda ne yaptığını üç satır testle '
        'bir kez yazarsın, sonsuza kadar güvende olursun.',
    gameEffect:
        'Test yazmak teknik borç birikimini durdurur. Test kapsamı düşükken '
        'hata kaynaklı olay kartları daha sık çıkar.',
    category: GlossaryCategory.quality,
  ),
  GlossaryTerm(
    id: 'hotfix',
    name: 'Hotfix',
    shortDefinition:
        'Canlıdaki kritik bir hatayı normal süreci atlayarak acilen düzelten '
        'küçük yama.',
    realLifeExample:
        'Gece 03:00\'te tek satır değiştirip doğrudan production\'a gönderme. '
        'Sorunu çözer, ertesi gün yeni bir sorun doğurur.',
    gameEffect:
        'Kriz kartlarındaki "hemen yamala" seçenekleri hotfix\'tir: krizi '
        'anında kapatır ama teknik borcu artırır.',
    category: GlossaryCategory.quality,
  ),
  GlossaryTerm(
    id: 'spaghetti_code',
    name: 'Spaghetti Code',
    shortDefinition:
        'Her şeyin her şeye bağlı olduğu, takip edilemez biçimde dolaşmış kod.',
    realLifeExample:
        'Bir butonun rengini değiştirmek için ödeme servisine dokunmak '
        'zorunda kaldığın kod tabanı.',
    gameEffect:
        'Yüksek teknik borcun görünen yüzüdür. %60 üstünde Zeynep sert uyarmaya '
        'başlar ve aksiyonların gelir etkisi düşer.',
    category: GlossaryCategory.engineering,
  ),
  GlossaryTerm(
    id: 'bottleneck',
    name: 'Bottleneck',
    shortDefinition: 'Bütün sistemin hızını tek başına belirleyen en yavaş halka — darboğaz.',
    realLifeExample:
        'On sunucu eklersin ama hepsi aynı veritabanına gider; veritabanı '
        'yetişemez. Darboğaz sunucu değil, veritabanıydı.',
    gameEffect:
        'Viral trafik olay kartında karşına çıkar: altyapıyı güçlendirmezsen '
        'gelen trafik gelire değil kayba dönüşür.',
    category: GlossaryCategory.business,
  ),
  GlossaryTerm(
    id: 'rollback',
    name: 'Rollback',
    shortDefinition:
        'Sorun çıkaran sürümü geri alıp önceki çalışan sürüme dönmek.',
    realLifeExample:
        'Yeni sürüm ödemeleri bozdu; iki dakikada eski sürüme dönülür, '
        'sorun sonra sakin kafayla aranır.',
    gameEffect:
        'Kriz kartlarında "geri al" seçeneğidir: zararı sınırlar, çoğunlukla '
        'biraz gelir ve değerleme kaybettirir ama teknik borç eklemez.',
    category: GlossaryCategory.infrastructure,
  ),
  GlossaryTerm(
    id: 'mvp',
    name: 'MVP',
    shortDefinition:
        'Minimum Viable Product: fikri test etmeye yetecek en küçük '
        'kullanılabilir ürün.',
    realLifeExample:
        'Altı ay mükemmel ürün yapmak yerine üç haftada çalışan bir sürüm '
        'çıkarıp gerçek kullanıcıya sormak.',
    gameEffect:
        'Oyunun başlangıç noktası budur: elinde küçük bir ürün ve 2.000\$ '
        'haftalık gelir var. Buradan 1.000.000\$ değerlemeye çıkman gerekiyor.',
    category: GlossaryCategory.business,
  ),
  GlossaryTerm(
    id: 'legacy_code',
    name: 'Legacy Code',
    shortDefinition:
        'Devraldığın, kimsenin tam olarak anlamadığı ama çalıştığı için '
        'dokunulmaya korkulan eski kod.',
    realLifeExample:
        'Yazarı iki yıl önce ayrılmış, testi olmayan, ama şirketin en çok para '
        'kazandıran modülü. Herkes ondan uzak durur.',
    gameEffect:
        'Legacy code krizi kartında karşına çıkar. Teknik borç yüksekse '
        'devraldığın kod daha pahalıya temizlenir.',
    category: GlossaryCategory.engineering,
  ),
  GlossaryTerm(
    id: 'code_review',
    name: 'Code Review',
    shortDefinition:
        'Bir geliştiricinin yazdığı kodun başka biri tarafından okunup '
        'değerlendirilmesi.',
    realLifeExample:
        'Can\'ın PR\'ındaki sonsuz döngüyü merge\'den önce Zeynep\'in '
        'yakalaması. On dakikalık okuma, bir gecelik incident\'ı önler.',
    gameEffect:
        'Senior çalışanlar code review yapar sayılır: ekipte senior varken '
        'teknik borç her hafta %2 azalır ve moral yükselir.',
    category: GlossaryCategory.process,
  ),
  GlossaryTerm(
    id: 'burnout',
    name: 'Burnout',
    shortDefinition:
        'Sürekli baskı ve aşırı yük sonucu gelen tükenmişlik. Ne pizzayla ne '
        'de zamla geçer.',
    realLifeExample:
        'Üç ay üst üste "bu sprint de sıkışık" denen ekipte insanlar önce '
        'sessizleşir, sonra istifa eder.',
    gameEffect:
        'Ekip Morali metriğidir. %30 altında aksiyonların etkisi zayıflar; '
        '%0\'a düşerse toplu istifa olur ve oyun biter.',
    category: GlossaryCategory.process,
  ),
  GlossaryTerm(
    id: 'on_call',
    name: 'On-call',
    shortDefinition: 'Mesai dışında da sistem arızalarına müdahale etmek üzere nöbette olmak.',
    realLifeExample:
        'Telefonun gece 02:40\'ta çalar, çünkü disk doldu. Ertesi gün yine '
        'işe gidersin.',
    gameEffect:
        'Teknik borç yüksekken gece alarmları artar; moral kaybı hızlanır. '
        'DevOps işe almak bu yükü ciddi biçimde azaltır.',
    category: GlossaryCategory.infrastructure,
  ),
];

/// Kimlikten terim bulur; bulunamazsa `null` döner.
GlossaryTerm? glossaryTermById(String id) {
  for (final term in kGlossaryTerms) {
    if (term.id == id) return term;
  }
  return null;
}

/// Verilen kategorideki terimler.
List<GlossaryTerm> glossaryTermsByCategory(GlossaryCategory category) =>
    kGlossaryTerms.where((term) => term.category == category).toList();
