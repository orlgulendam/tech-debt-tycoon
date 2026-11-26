/// Olay kartları.
///
/// Her kartın en az iki seçeneği var ve her seçeneğin etkisi sayısal olarak
/// tanımlı. Tasarım kuralı: hiçbir seçenek "bedava doğru cevap" olmasın —
/// her birinin bir bedeli olsun.
library;

import '../models/event_card.dart';
import '../models/event_choice.dart';
import '../models/game_effect.dart';

/// Oyundaki bütün olay kartları.
const List<EventCard> kEventCards = [
  // 1 -------------------------------------------------------------------
  EventCard(
    id: 'event_friday_deploy',
    title: 'Cuma 17:55',
    narration:
        'Mert kapıda: "Şu ödeme güncellemesi bu akşam çıksın, pazartesi '
        'yatırımcıya göstereceğim." Saat 17:55. Elif çoktan montunu giydi.',
    speakerId: 'mert',
    severity: EventSeverity.warning,
    choices: [
      EventChoice(
        id: 'deploy_now',
        label: 'Deploy et, ne olacak ki',
        effect: GameEffect(
          revenueDelta: 700,
          valuationDelta: 15000,
          techDebtDelta: 12,
          moraleDelta: -10,
        ),
        outcomeText:
            'Çıktı. 19:20\'de ödeme hataları başladı. Hafta sonu boyunca '
            'üç kişi Slack\'te yaşadı. Mert sunumunu yaptı ama kimse mutlu değil.',
        outcomeSpeakerId: 'elif',
      ),
      EventChoice(
        id: 'deploy_monday',
        label: 'Pazartesi sabah çıkarırız',
        effect: GameEffect(valuationDelta: 3000, moraleDelta: 6),
        outcomeText:
            'Pazartesi 09:30\'da sakin kafayla çıktı, tek sorun yaşanmadı. '
            'Mert sunumu bir gün erteledi ve hayatta kaldı.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'deploy_canary',
        label: 'Kullanıcıların %5\'ine aç, izle',
        effect: GameEffect(
          budgetDelta: -800,
          revenueDelta: 400,
          valuationDelta: 9000,
          techDebtDelta: 2,
          moraleDelta: 2,
        ),
        outcomeText:
            'Kademeli açtık. %5\'te bir hata yakalandı, 40 dakikada düzeldi, '
            'kimse fark etmedi. Elif bunu yıl sonu değerlendirmesine yazacak.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
    ],
  ),

  // 2 -------------------------------------------------------------------
  EventCard(
    id: 'event_prod_db_deleted',
    title: 'O Komut Neydi?',
    narration:
        'Can çok sessiz. Sonra konuşuyor: "Bir temizlik scripti çalıştırdım. '
        'Sanırım staging\'de değildim." Production veritabanı boş.',
    speakerId: 'can',
    severity: EventSeverity.critical,
    minWeek: 3,
    choices: [
      EventChoice(
        id: 'restore_backup',
        label: 'Yedekten dön (son yedek 6 saat önce)',
        effect: GameEffect(
          budgetDelta: -2500,
          revenueDelta: -300,
          valuationDelta: -12000,
          moraleDelta: -5,
        ),
        outcomeText:
            'Yedek çalıştı. Altı saatlik veri gitti, 40 kullanıcı siparişini '
            'tekrar girdi. Elif o akşam yedek sıklığını 15 dakikaya düşürdü.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'manual_rebuild',
        label: 'Logları tarayıp elle yeniden kur',
        effect: GameEffect(
          budgetDelta: -1200,
          techDebtDelta: 18,
          moraleDelta: -16,
        ),
        outcomeText:
            'İki gün, dört kişi, sayısız kahve. Veri geri geldi ama o sırada '
            'yazılan "geçici" kurtarma scriptleri kod tabanında kaldı.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'revoke_access',
        label: 'Yedekten dön ve production erişimlerini kıs',
        effect: GameEffect(
          budgetDelta: -3000,
          valuationDelta: -8000,
          techDebtDelta: -5,
          moraleDelta: 3,
        ),
        outcomeText:
            'Veri döndü, yetkiler sıkılaştı. Can artık production\'a bakamıyor '
            've bundan gizlice memnun.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
    ],
  ),

  // 3 -------------------------------------------------------------------
  EventCard(
    id: 'event_viral_traffic',
    title: 'Viral Olduk',
    narration:
        'Bir influencer ürünü paylaştı. Trafik 40 katına çıktı. Elif '
        'grafiklere bakıyor: "Veritabanı darboğazda, 20 dakikamız var."',
    speakerId: 'elif',
    severity: EventSeverity.warning,
    minWeek: 2,
    choices: [
      EventChoice(
        id: 'scale_up',
        label: 'Parayı bas, altyapıyı büyüt',
        effect: GameEffect(
          budgetDelta: -4000,
          revenueDelta: 1600,
          valuationDelta: 40000,
          moraleDelta: 4,
        ),
        outcomeText:
            'Sistem ayakta kaldı. Binlerce yeni kullanıcı, tarihin en yüksek '
            'geliri ve Elif\'in hayatında ilk kez gurur duyduğu bir grafik.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'quick_cache',
        label: 'Aceleyle cache ekle, idare etsin',
        effect: GameEffect(
          budgetDelta: -500,
          revenueDelta: 900,
          valuationDelta: 22000,
          techDebtDelta: 14,
          moraleDelta: -3,
        ),
        outcomeText:
            'Cache tuttu, site ayakta kaldı. Ama hiçbir yerde dokümante '
            'edilmeyen bir cache katmanı doğdu. Zeynep ona "o şey" diyor.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'let_it_burn',
        label: 'Hiçbir şey yapma, dalga geçsin',
        effect: GameEffect(
          revenueDelta: -200,
          valuationDelta: -15000,
          moraleDelta: -8,
        ),
        outcomeText:
            'Site 3 saat çöktü. Influencer bu kez "çalışmıyor" diye paylaştı. '
            'Hayatta en pahalı şey, kaçırılmış fırsat.',
        outcomeSpeakerId: 'mert',
      ),
    ],
  ),

  // 4 -------------------------------------------------------------------
  EventCard(
    id: 'event_legacy_crisis',
    title: 'Kimsenin Dokunmadığı Modül',
    narration:
        'Zeynep ekranı çeviriyor: "Fatura modülü. Yazarı iki yıl önce ayrıldı, '
        'testi yok, ama bütün paramız oradan geçiyor. Ve artık hata veriyor."',
    speakerId: 'zeynep',
    severity: EventSeverity.critical,
    minWeek: 4,
    choices: [
      EventChoice(
        id: 'rewrite_module',
        label: 'Baştan yaz, bu iş bitsin',
        effect: GameEffect(
          budgetDelta: -5000,
          revenueDelta: 300,
          techDebtDelta: -22,
          moraleDelta: 10,
        ),
        outcomeText:
            'İki hafta sürdü, bütçeyi yedi. Ama artık modülün testi var ve '
            'Zeynep ilk kez tatile çıkmayı düşünüyor.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'patch_module',
        label: 'Yamala, çalışsın yeter',
        effect: GameEffect(
          budgetDelta: -600,
          revenueDelta: 200,
          techDebtDelta: 16,
          moraleDelta: -7,
        ),
        outcomeText:
            'Yama tuttu. Modül şimdi daha da anlaşılmaz; artık iki kişi birden '
            'korkuyor. Sorun çözülmedi, randevu alındı.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'wrap_module',
        label: 'Etrafına test yaz, sonra parça parça değiştir',
        effect: GameEffect(
          budgetDelta: -2200,
          techDebtDelta: -10,
          moraleDelta: 5,
        ),
        outcomeText:
            'Önce testlerle çevreledik, sonra içini yavaşça değiştirdik. '
            'Sıkıcı, yavaş, doğru. Zeynep gözle görülür biçimde rahatladı.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
    ],
  ),

  // 5 -------------------------------------------------------------------
  EventCard(
    id: 'event_investor_pitch',
    title: 'Yatırımcı Sunumu',
    narration:
        'Mert heyecanlı: "Yarın sunum var. Teknik borçtan bahsetmeyeceğiz, '
        'değil mi? Sadece büyüme grafiği göstereceğiz."',
    speakerId: 'mert',
    severity: EventSeverity.info,
    minWeek: 5,
    choices: [
      EventChoice(
        id: 'pitch_growth',
        label: 'Sadece büyümeyi göster',
        effect: GameEffect(
          valuationDelta: 55000,
          techDebtDelta: 6,
          moraleDelta: -4,
        ),
        outcomeText:
            'Yatırımcı etkilendi, değerleme uçtu. Ekip sunumu izlerken '
            'birbirine baktı: kimse o grafiğin arkasındaki kodu görmüyor.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'pitch_honest',
        label: 'Teknik borcu da anlat, yol haritası ver',
        effect: GameEffect(
          valuationDelta: 30000,
          revenueDelta: 400,
          moraleDelta: 9,
        ),
        outcomeText:
            'Yatırımcı "ilk kez bir ekip bana riski kendisi söyledi" dedi. '
            'Değerleme daha ölçülü arttı ama güven kazanıldı.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'pitch_demo',
        label: 'Canlı demo yap',
        effect: GameEffect(
          valuationDelta: 20000,
          techDebtDelta: 3,
          moraleDelta: -2,
        ),
        outcomeText:
            'Demo\'nun ortasında bir buton çalışmadı. Mert "bu bir feature" '
            'dedi ve bir şekilde kurtardı. Değerleme yine de arttı.',
        outcomeSpeakerId: 'mert',
      ),
    ],
  ),

  // 6 -------------------------------------------------------------------
  EventCard(
    id: 'event_force_push',
    title: 'Force Push',
    narration:
        'Can fısıldıyor: "Bir çakışma vardı, internette bir komut buldum. '
        '`--force` yazıyordu." Son iki günün commit\'leri main\'de yok.',
    speakerId: 'can',
    severity: EventSeverity.critical,
    minWeek: 2,
    choices: [
      EventChoice(
        id: 'recover_reflog',
        label: 'Zeynep\'i çağır, reflog\'dan kurtar',
        effect: GameEffect(
          budgetDelta: -400,
          techDebtDelta: 2,
          moraleDelta: -3,
        ),
        outcomeText:
            'Zeynep 25 dakikada her şeyi geri getirdi ve Can\'a reflog\'u '
            'öğretti. Can bunu bir daha asla yapmayacak. Muhtemelen.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'rewrite_lost_work',
        label: 'İki günü yeniden yaz',
        effect: GameEffect(
          revenueDelta: -200,
          valuationDelta: -6000,
          techDebtDelta: 9,
          moraleDelta: -12,
        ),
        outcomeText:
            'Aynı işi ikinci kez yapmak insanı yorar. Yeniden yazılan kod '
            'ilkinden aceleci oldu; kimse ikinci kez özen göstermiyor.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'protect_branch',
        label: 'Kurtar ve branch koruması aç',
        effect: GameEffect(
          budgetDelta: -700,
          techDebtDelta: -4,
          moraleDelta: 5,
        ),
        outcomeText:
            'Kod geri geldi, main artık korumalı. Elif "bunu ilk hafta '
            'yapmamız gerekiyordu" dedi ve kimse itiraz edemedi.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
    ],
  ),

  // 7 -------------------------------------------------------------------
  EventCard(
    id: 'event_cloud_bill',
    title: 'Bulut Faturası',
    narration:
        'Elif ekranı gösteriyor: "Bu ayın sunucu faturası üç katına çıktı. '
        'Sebep: geçen ay açılan ve kapatılmayı unutulan test ortamları."',
    speakerId: 'elif',
    severity: EventSeverity.warning,
    minWeek: 3,
    choices: [
      EventChoice(
        id: 'optimize_infra',
        label: 'Altyapıyı optimize et',
        effect: GameEffect(
          budgetDelta: -1500,
          revenueDelta: 500,
          techDebtDelta: -8,
          moraleDelta: 3,
        ),
        outcomeText:
            'Kullanılmayan ortamlar kapatıldı, boyutlar düşürüldü. Fatura '
            '%45 azaldı ve Elif otomatik kapatma scripti yazdı.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'pay_bill',
        label: 'Öde, şimdi uğraşamam',
        effect: GameEffect(budgetDelta: -4500, moraleDelta: -2),
        outcomeText:
            'Fatura ödendi. Gelecek ay aynı fatura yine gelecek. Elif '
            'takvime "bunu konuşacağız" diye bir hatırlatma koydu.',
        outcomeSpeakerId: 'elif',
      ),
      EventChoice(
        id: 'kill_staging',
        label: 'Staging\'i tamamen kapat',
        effect: GameEffect(
          budgetDelta: -200,
          revenueDelta: 200,
          techDebtDelta: 13,
          moraleDelta: -9,
        ),
        outcomeText:
            'Fatura düştü. Artık test ortamı yok, yani production test ortamı. '
            'Elif bunu bir e-postayla resmen protesto etti.',
        outcomeSpeakerId: 'elif',
      ),
    ],
  ),

  // 8 -------------------------------------------------------------------
  EventCard(
    id: 'event_competitor_launch',
    title: 'Rakip Çıktı',
    narration:
        'Mert telefonu masaya koyuyor: "Rakip bizim altı aylık yol '
        'haritamızı bugün yayınladı. Hem de ücretsiz."',
    speakerId: 'mert',
    severity: EventSeverity.warning,
    minWeek: 4,
    choices: [
      EventChoice(
        id: 'rush_features',
        label: 'Üç feature\'ı bir haftada çıkar',
        effect: GameEffect(
          revenueDelta: 900,
          valuationDelta: 25000,
          techDebtDelta: 22,
          moraleDelta: -14,
        ),
        outcomeText:
            'Üçü de çıktı, ikisi yarım çalışıyor. Basın iyi yazdı, kullanıcı '
            'yorumları karışık. Ekip tükenmiş durumda.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'focus_quality',
        label: 'Tek bir şeyi çok iyi yap',
        effect: GameEffect(
          revenueDelta: 600,
          valuationDelta: 18000,
          techDebtDelta: -3,
          moraleDelta: 7,
        ),
        outcomeText:
            'Bir özelliği kusursuz çıkardık. Rakip on özelliği yarım çıkardı. '
            'Kullanıcılar farkı iki hafta içinde gördü.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'cut_price',
        label: 'Fiyatı düşür, pazarda kal',
        effect: GameEffect(
          revenueDelta: -400,
          valuationDelta: 8000,
          moraleDelta: -3,
        ),
        outcomeText:
            'Kullanıcı sayısı arttı, gelir düştü. Mert buna "pazar payı '
            'yatırımı" diyor. Muhasebe başka bir şey diyor.',
        outcomeSpeakerId: 'mert',
      ),
    ],
  ),

  // 9 -------------------------------------------------------------------
  EventCard(
    id: 'event_key_employee_leaving',
    title: 'O Konuşma',
    narration:
        'Zeynep kapıyı kapatıyor: "Bir şey konuşmak istiyorum. Son üç ay '
        'sadece yangın söndürdüm. Bu benim yapmak istediğim iş değil."',
    speakerId: 'zeynep',
    severity: EventSeverity.critical,
    minWeek: 5,
    choices: [
      EventChoice(
        id: 'give_refactor_time',
        label: 'Bir sprint ver: istediği gibi temizlesin',
        effect: GameEffect(
          revenueDelta: -200,
          techDebtDelta: -20,
          moraleDelta: 16,
        ),
        outcomeText:
            'Zeynep kaldı. Bir hafta boyunca kod tabanını temizledi ve '
            'pazartesi günü yıllardır ilk kez gülümseyerek geldi.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'offer_raise',
        label: 'Zam teklif et',
        effect: GameEffect(
          budgetDelta: -3500,
          revenueDelta: 100,
          moraleDelta: 4,
        ),
        outcomeText:
            'Zam kabul edildi. Zeynep kaldı ama sorun para değildi; üç hafta '
            'sonra aynı konuşmayı tekrar yapacaksınız.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'let_go',
        label: 'Anlayışla karşıla, yolun açık olsun',
        effect: GameEffect(
          revenueDelta: -800,
          valuationDelta: -20000,
          techDebtDelta: 12,
          moraleDelta: -18,
        ),
        outcomeText:
            'Zeynep gitti. Yanında kimsenin yazmadığı dokümantasyonu ve '
            'herkesin ihtiyaç duyduğu bağlamı da götürdü.',
        outcomeSpeakerId: 'elif',
      ),
    ],
  ),

  // 10 ------------------------------------------------------------------
  EventCard(
    id: 'event_security_report',
    title: 'Güvenlik Bildirimi',
    narration:
        'Elif ciddi: "Bir araştırmacı e-posta attı. API\'de yetkilendirme '
        'açığı var; isteyen başkasının verisini okuyabiliyor. 90 gün süre verdi."',
    speakerId: 'elif',
    severity: EventSeverity.critical,
    minWeek: 3,
    choices: [
      EventChoice(
        id: 'fix_properly',
        label: 'Hemen düzelt, sonra güvenlik denetimi yap',
        effect: GameEffect(
          budgetDelta: -3800,
          valuationDelta: 6000,
          techDebtDelta: -12,
          moraleDelta: 6,
        ),
        outcomeText:
            'Açık 48 saatte kapandı, denetim üç tane daha buldu. Araştırmacıya '
            'teşekkür edildi, o da olumlu bir yazı yazdı.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'quick_patch',
        label: 'Sadece bu açığı yamala',
        effect: GameEffect(
          budgetDelta: -600,
          techDebtDelta: 7,
          moraleDelta: -4,
        ),
        outcomeText:
            'Bildirilen açık kapandı. Aynı hatanın diğer dört uç noktadaki '
            'hâli duruyor; onları henüz kimse bildirmedi.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'ignore_report',
        label: 'Görmezden gel, 90 gün çok uzun',
        effect: GameEffect(
          valuationDelta: -35000,
          techDebtDelta: 15,
          moraleDelta: -15,
        ),
        outcomeText:
            '91. günde açık yayınlandı. Basın yazdı, iki kurumsal müşteri '
            'sözleşmeyi askıya aldı. Elif hiçbir şey söylemedi, bu daha kötü.',
        outcomeSpeakerId: 'elif',
      ),
    ],
  ),

  // 11 ------------------------------------------------------------------
  EventCard(
    id: 'event_debt_interest',
    title: 'Borcun Faizi',
    narration:
        'Zeynep sayıları gösteriyor: "Basit bir buton eklemek üç gün sürdü. '
        'Üç ay önce üç saatti. Teknik borcun faizi bu."',
    speakerId: 'zeynep',
    severity: EventSeverity.warning,
    minWeek: 6,
    choices: [
      EventChoice(
        id: 'pay_debt_down',
        label: 'İki hafta sadece borç ödemeye ayır',
        effect: GameEffect(
          budgetDelta: -2000,
          revenueDelta: -200,
          techDebtDelta: -28,
          moraleDelta: 12,
        ),
        outcomeText:
            'İki hafta hiçbir feature çıkmadı. Üçüncü hafta ekip eskisinin '
            'iki katı hızla çalışıyordu. Zeynep hiçbir şey demedi, demesi gerekmedi.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'hire_more',
        label: 'Daha fazla geliştirici al, hız artsın',
        effect: GameEffect(
          budgetDelta: -2500,
          revenueDelta: 400,
          techDebtDelta: 10,
          moraleDelta: -5,
        ),
        outcomeText:
            'Yeni gelenler kodu anlamak için üç hafta harcadı ve bu arada '
            'kendi yorumlarını ekledi. Dokuz kadın bir ayda bir bebek doğuramıyor.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'push_through',
        label: 'Devam, yavaşlık normal',
        effect: GameEffect(
          revenueDelta: 300,
          valuationDelta: 8000,
          techDebtDelta: 14,
          moraleDelta: -11,
        ),
        outcomeText:
            'Devam ettik. Her sprint bir öncekinden az iş çıkıyor ve kimse '
            'bunu toplantıda söylemiyor.',
        outcomeSpeakerId: 'zeynep',
      ),
    ],
  ),

  // 12 ------------------------------------------------------------------
  EventCard(
    id: 'event_successful_launch',
    title: 'İyi Haber',
    narration:
        'Can koşarak geliyor: "Yeni sürüm çıktı ve... hiçbir şey bozulmadı! '
        'Kullanıcı yorumları çok iyi!" Elif de şaşkın: "Gerçekten öyle."',
    speakerId: 'can',
    severity: EventSeverity.positive,
    minWeek: 3,
    choices: [
      EventChoice(
        id: 'celebrate',
        label: 'Kutla, ekip bunu hak etti',
        effect: GameEffect(
          budgetDelta: -1200,
          revenueDelta: 700,
          valuationDelta: 20000,
          moraleDelta: 14,
        ),
        outcomeText:
            'Akşam yemeği, erken çıkış, gerçek bir tebrik. Ekip ertesi hafta '
            'daha hızlı çalıştı; moral bir maliyet değil, bir yatırım.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'ride_momentum',
        label: 'İvmeyi kullan, hemen sıradakine geç',
        effect: GameEffect(
          revenueDelta: 1100,
          valuationDelta: 32000,
          techDebtDelta: 9,
          moraleDelta: -6,
        ),
        outcomeText:
            'Hemen sıradaki işe geçtik. Gelir arttı ama kimse başarıyı '
            'hissetmedi. Kutlanmayan başarı, yapılmamış gibi geliyor.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'write_postmortem',
        label: 'Neden iyi gitti, onu yaz',
        effect: GameEffect(
          valuationDelta: 10000,
          techDebtDelta: -7,
          moraleDelta: 8,
        ),
        outcomeText:
            'Elif "başarı post-mortem\'i" yazdı. Neyin işe yaradığı artık '
            'yazılı: iyi test kapsamı ve kademeli yayın. Bir sonraki sürüm de iyi geçti.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
    ],
  ),

  // 13 ------------------------------------------------------------------
  EventCard(
    id: 'event_intern_genius',
    title: 'Can Bir Şey Buldu',
    narration:
        'Can çekinerek geliyor: "Şu yavaş sorguya baktım. Bir index eksikti. '
        'Ekledim, 8 saniyeden 60 milisaniyeye indi. Yanlış mı yaptım?"',
    speakerId: 'can',
    severity: EventSeverity.positive,
    minWeek: 4,
    choices: [
      EventChoice(
        id: 'praise_and_review',
        label: 'Tebrik et, review\'dan geçir, yayınla',
        effect: GameEffect(
          revenueDelta: 500,
          valuationDelta: 12000,
          techDebtDelta: -6,
          moraleDelta: 11,
        ),
        outcomeText:
            'Zeynep review\'da tek kelime yazdı: "güzel iş". Can o ekran '
            'görüntüsünü hâlâ saklıyor. Sistem de gerçekten hızlandı.',
        outcomeSpeakerId: 'zeynep',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'ship_immediately',
        label: 'Harika, direkt production\'a al',
        effect: GameEffect(
          revenueDelta: 600,
          valuationDelta: 14000,
          techDebtDelta: 8,
          moraleDelta: 5,
        ),
        outcomeText:
            'Sorgu hızlandı. Ama index yazma işlemlerini yavaşlattı ve bunu '
            'iki gün sonra Elif alarmlardan öğrendi.',
        outcomeSpeakerId: 'elif',
      ),
    ],
  ),

  // 14 ------------------------------------------------------------------
  EventCard(
    id: 'event_oncall_night',
    title: 'Gece 02:40',
    narration:
        'Telefon çalıyor. Elif\'in sesi yorgun: "Bu hafta üçüncü alarm. '
        'Hepsi aynı sebepten. Ben artık uyumak istiyorum."',
    speakerId: 'elif',
    severity: EventSeverity.warning,
    minWeek: 4,
    choices: [
      EventChoice(
        id: 'fix_root_cause',
        label: 'Kök nedeni çöz',
        effect: GameEffect(
          budgetDelta: -1800,
          techDebtDelta: -14,
          moraleDelta: 10,
        ),
        outcomeText:
            'Kök neden bulundu ve kapatıldı. Alarmlar durdu. Elif bir hafta '
            'boyunca telefonuna bakmadan uyudu ve bunu herkese anlattı.',
        outcomeSpeakerId: 'elif',
        resolvesCrisis: true,
      ),
      EventChoice(
        id: 'rotate_oncall',
        label: 'Nöbeti ekibe dağıt',
        effect: GameEffect(moraleDelta: -6, techDebtDelta: -3),
        outcomeText:
            'Nöbet paylaşıldı. Elif rahatladı, diğerleri rahatsız oldu. '
            'En azından artık sorunun ne kadar can sıkıcı olduğunu herkes biliyor.',
        outcomeSpeakerId: 'zeynep',
      ),
      EventChoice(
        id: 'silence_alarm',
        label: 'Alarmın eşiğini yükselt, sussun',
        effect: GameEffect(
          revenueDelta: 200,
          techDebtDelta: 11,
          moraleDelta: -8,
        ),
        outcomeText:
            'Alarm sustu. Sorun susmadı. Bir sonraki sefer problemi '
            'monitoring\'den değil kullanıcı şikâyetlerinden öğreneceksiniz.',
        outcomeSpeakerId: 'elif',
      ),
    ],
  ),
];

/// Kimlikten olay kartı bulur; bulunamazsa `null` döner.
EventCard? eventCardById(String id) {
  for (final card in kEventCards) {
    if (card.id == id) return card;
  }
  return null;
}

/// Verilen haftada çıkabilecek olay kartları.
List<EventCard> eventCardsAvailableAt(int week) =>
    kEventCards.where((card) => card.minWeek <= week).toList();
