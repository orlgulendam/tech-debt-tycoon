import 'string_keys.dart';

/// Türkçe metinler.
///
/// Ton: doğal, kısa ve yazılımcı mizahı taşıyan bir dil. Placeholder'lar
/// süslü parantez ile yazılır (ör. `{week}`) ve [AppStrings.format] ile
/// doldurulur.
const Map<StringKey, String> kStringsTr = {
  // --- Uygulama genel ---
  StringKey.appTitle: 'Tech Debt Tycoon',
  StringKey.appTagline:
      'Bir yazılım girişiminin CTO\'su olmak bu kadar mı zor?',

  // --- Alt navigasyon ---
  StringKey.navOffice: 'Ofis',
  StringKey.navTeam: 'Ekip',
  StringKey.navGlossary: 'Sözlük',
  StringKey.navLog: 'Log',

  // --- Metrik etiketleri ---
  StringKey.metricBudget: 'Bütçe',
  StringKey.metricValuation: 'Değerleme',
  StringKey.metricWeeklyRevenue: 'Haftalık Gelir',
  StringKey.metricWeeklyRevenueShort: 'Gelir',
  StringKey.metricTechDebt: 'Teknik Borç',
  StringKey.metricTeamMorale: 'Ekip Morali',
  StringKey.metricWeek: 'Hafta',
  StringKey.metricTeamSize: 'Kadro',
  StringKey.metricNetCashFlow: 'Net Nakit Akışı',

  // --- Ofis ekranı ---
  StringKey.officeTitle: 'Ofis',
  StringKey.officeWeekLabel: 'Hafta {week}',
  StringKey.officeChooseAction: 'Bu hafta ne yapıyoruz?',
  StringKey.officeActionsSectionTitle: 'Sprint Aksiyonları',
  StringKey.officeNextWeek: 'Sprint\'i Kapat',
  StringKey.officeUnicornProgress: 'Unicorn\'a kalan: {remaining}',
  StringKey.officeAdvisorSectionTitle: 'Danışman',

  // --- İpucu / danışman ---
  StringKey.hintSheetTitle: 'Danışman Ne Diyor?',
  StringKey.hintAdviceLabel: 'Tavsiye',
  StringKey.hintReasonLabel: 'Neden?',
  StringKey.hintMetricLabel: 'İlgili metrik',
  StringKey.hintFreeRemaining: '{count} ücretsiz ipucu hakkın kaldı',
  StringKey.hintNoFreeLeft:
      'Ücretsiz ipuçları bitti. Danışman bedava çalışmıyor.',
  StringKey.hintWatchAdButton: 'Reklam izle, danışman tut',
  StringKey.hintAskButton: 'Danışmana sor',
  StringKey.hintEverythingFine:
      'Her şey yolunda görünüyor. Bu his genelde uzun sürmez.',

  // --- İpucu metinleri ---
  StringKey.hintDebtCriticalAdvice:
      'Her şeyi bırak, refactoring sprinti yap. Şimdi.',
  StringKey.hintDebtCriticalReason:
      'Teknik borç %{value}. Sunucular %100\'de yanıyor ve sen oraya iki '
      'kötü haftalık mesafedesin. Yeni feature artık gelir değil risk getiriyor.',
  StringKey.hintDebtHighAdvice: 'Bir sprint\'i borç ödemeye ayır.',
  StringKey.hintDebtHighReason:
      'Teknik borç %{value}. Bu seviyenin üstünde gelirin bir kısmını '
      'kaybediyorsun ve ekip her hafta moral eritiyor.',
  StringKey.hintMoraleCriticalAdvice:
      'Ekip motivasyonuna bütçe ayır, başka hiçbir şey yapma.',
  StringKey.hintMoraleCriticalReason:
      'Moral %{value}. Sıfıra inerse ekip toplu istifa eder ve oyun biter. '
      'Bu noktada hiçbir feature o kadar önemli değil.',
  StringKey.hintMoraleLowAdvice:
      'Ekibe nefes aldır: motivasyon ya da refactoring.',
  StringKey.hintMoraleLowReason:
      'Moral %{value}. Düşük moralde insanlar daha çok hata yapıyor, '
      'hatalar da morali daha çok düşürüyor. Döngüyü şimdi kır.',
  StringKey.hintBudgetCriticalAdvice: 'Hemen gelir getiren bir şey çıkar.',
  StringKey.hintBudgetCriticalReason:
      'Bütçe {value}\$ ve haftalık maaş yükün bunun yarısından fazla. '
      'İki hafta içinde bordroyu ödeyemezsin.',
  StringKey.hintBudgetLowAdvice:
      'Gelire odaklan; pahalı aksiyonları şimdilik ertele.',
  StringKey.hintBudgetLowReason:
      'Bütçe {value}\$. Kasa 0\$\'a inerse iflas. Önce nakit, sonra temizlik.',
  StringKey.hintCashFlowNegativeAdvice:
      'Geliri artır: haftalık nakit akışın negatif.',
  StringKey.hintCashFlowNegativeReason:
      'Her hafta {value}\$ kaybediyorsun. Maaşlar gelirden fazla; '
      'bu gidişle bütçe kendi kendine tükenir.',
  StringKey.hintHireTeamAdvice:
      'İşe alım yap. Tek başına 1.000.000\$\'a çıkamazsın.',
  StringKey.hintHireTeamReason:
      'Ekip boş ve bütçen {value}\$. Doğru kişi hem gelir getirir hem de '
      'teknik borcu erittiği için kendini amorti eder.',
  StringKey.hintSlowGrowthAdvice: 'Değerlemeyi büyütmeye odaklan.',
  StringKey.hintSlowGrowthReason:
      '{week}. haftadasın ve hedefin %{value}\'ini tamamladın. Kaynaklar '
      'sağlamken büyümeye basmanın tam zamanı.',
  StringKey.hintAllGoodAdvice: 'Dengeyi koru: bir feature, bir temizlik.',
  StringKey.hintAllGoodReason:
      'Bütün metrikler güvenli aralıkta. Teknik borç birikmeden büyümeye '
      'devam edebilirsin — bu durum genelde uzun sürmez, kıymetini bil.',

  // --- Sahte reklam ---
  StringKey.adSheetTitle: 'Sponsorlu İçerik',
  StringKey.adLoading: 'Reklam yükleniyor... (söz veriyoruz, kısa)',
  StringKey.adRewardGranted: 'Danışman tutuldu! Bir ipucu hakkı eklendi.',
  StringKey.adFailed: 'Reklam yüklenemedi. Belki de evren sana iyilik yapıyor.',
  StringKey.adCancel: 'Vazgeç',

  // --- Sprint sonucu ---
  StringKey.sprintResultTitle: 'Hafta {week} kapandı',
  StringKey.sprintResultActionLabel: 'Bu hafta ne yaptın',
  StringKey.sprintResultRevenue: 'Gelir tahsilatı',
  StringKey.sprintResultValuationGrowth: 'Değerleme büyümesi',
  StringKey.sprintResultActionEffect: 'Aksiyonun etkisi',
  StringKey.sprintResultTeamEffect: 'Ekibin etkisi',
  StringKey.sprintResultDebtDrift: 'Kod çürümesi',
  StringKey.sprintResultHired: '{name} ekibe katıldı',
  StringKey.sprintResultEventIncoming: 'Bir şeyler oluyor...',
  StringKey.sprintResultCalmWeek: 'Sakin bir hafta. Tadını çıkar.',
  StringKey.sprintResultContinue: 'Sonraki Hafta',

  // --- Olay kartları ---
  StringKey.eventSheetTitle: 'Beklenmedik Gelişme',
  StringKey.eventChooseOption: 'Karar senin:',
  StringKey.eventOutcomeTitle: 'Sonuç',
  StringKey.eventContinueButton: 'Devam',

  // --- Ekip ekranı ---
  StringKey.teamTitle: 'Ekip',
  StringKey.teamEmptyMessage: 'Henüz kimse yok. Şu an bütün şirket sensin; commit\'ler de, bug\'lar da senin.',
  StringKey.teamRosterSectionTitle: 'Kadro',
  StringKey.teamHireSectionTitle: 'İşe Alım',
  StringKey.teamHireButton: 'İşe Al',
  StringKey.teamSalaryLabel: 'Maaş',
  StringKey.teamRevenueLabel: 'Gelir katkısı',
  StringKey.teamDebtEffectLabel: 'Teknik borç etkisi',
  StringKey.teamMoraleEffectLabel: 'Moral etkisi',
  StringKey.teamNetValueLabel: 'Haftalık net',
  StringKey.teamPassiveEffectLabel: 'Haftalık pasif etki',
  StringKey.teamInsufficientBudget: 'Bütçe yetmiyor. Maaş bordrosu şaka değil.',
  StringKey.teamHiredMessage: '{name} ekibe katıldı. Hoş gelsin!',

  // --- Çalışan seviyeleri ---
  StringKey.levelJunior: 'Junior',
  StringKey.levelMid: 'Mid',
  StringKey.levelSenior: 'Senior',
  StringKey.levelDevops: 'DevOps',

  // --- Sözlük ekranı ---
  StringKey.glossaryTitle: 'Sözlük',
  StringKey.glossarySearchHint: 'Terim ara...',
  StringKey.glossaryNoResults: 'Bu terim sözlükte yok. Belki sen uydurdun?',
  StringKey.glossaryDefinitionLabel: 'Nedir?',
  StringKey.glossaryRealLifeLabel: 'Gerçek hayatta',
  StringKey.glossaryGameEffectLabel: 'Oyundaki etkisi',
  StringKey.glossaryCategoryAll: 'Tümü',
  StringKey.glossaryCategoryEngineering: 'Kod & Mimari',
  StringKey.glossaryCategoryProcess: 'Süreç',
  StringKey.glossaryCategoryInfrastructure: 'Altyapı',
  StringKey.glossaryCategoryQuality: 'Kalite',
  StringKey.glossaryCategoryBusiness: 'Ürün & İş',

  // --- Log & Kariyer ekranı ---
  StringKey.logTitle: 'Log & Kariyer',
  StringKey.logEmptyMessage:
      'Henüz tamamlanmış oyun yok. İlk iflasın her zaman en özeldir.',
  StringKey.logHistorySectionTitle: 'Geçmiş Oyunlar',
  StringKey.logStatsSectionTitle: 'Kariyer Özeti',
  StringKey.logBestValuation: 'En yüksek değerleme',
  StringKey.logTotalGames: 'Oynanan oyun',
  StringKey.logTotalWins: 'Unicorn sayısı',
  StringKey.logLongestRun: 'En uzun seri',
  StringKey.logRecordWeeks: '{weeks}. hafta',
  StringKey.logRecordCrises: '{count} kriz çözüldü',
  StringKey.logOutcomeWin: 'Unicorn',
  StringKey.logOutcomeLoss: 'Battı',

  // --- Oyun sonu ---
  StringKey.gameOverWonTitle: 'UNICORN! 🦄',
  StringKey.gameOverWonSubtitle: 'Değerleme 1.000.000\$. Teknik borç hâlâ orada ama artık senin problemin değil.',
  StringKey.gameOverLostTitle: 'Oyun Bitti',
  StringKey.lossReasonBankruptcy:
      'Bütçe tükendi. Maaş günü geldi, kasa boş. Klasik.',
  StringKey.lossReasonServerMeltdown:
      'Teknik borç %100. Sunucular yandı, loglar bile kaçtı.',
  StringKey.lossReasonMassResignation:
      'Moral sıfır. Ekip toplu istifa etti; Slack\'te sadece sen kaldın.',
  StringKey.gameOverWeeksLabel: 'Dayanılan hafta',
  StringKey.gameOverValuationLabel: 'Final değerleme',
  StringKey.gameOverCrisesLabel: 'Çözülen kriz',
  StringKey.gameOverCtoNoteLabel: 'CTO Notu',
  StringKey.gameOverRestartButton: 'Yeniden Dene',

  // --- CTO notları ---
  StringKey.ctoNoteWonClean:
      'Unicorn oldun ve kod tabanı hâlâ okunabilir. Bu ikisini birlikte '
      'başaran CTO sayısı sandığından az. Zeynep sana bir kahve borçlu.',
  StringKey.ctoNoteWonWithDebt:
      'Hedefe ulaştın ama arkanda bir enkaz bıraktın. Değerleme 1.000.000\$, '
      'teknik borç ise bir sonraki CTO\'nun problemi. Klasik exit.',
  StringKey.ctoNoteLostBankruptcy:
      'Kasa boşaldı. Ürün çalışıyordu, ekip iyiydi, sadece para bitti — '
      'girişimlerin yarısı tam olarak böyle ölüyor.',
  StringKey.ctoNoteLostMeltdown:
      'Teknik borç %100. Her hafta "sonra düzeltiriz" dedin, sonra hiç '
      'gelmedi. Sunucular senden önce pes etti.',
  StringKey.ctoNoteLostResignation:
      'Ekip gitti. Kod kaldı, ürün kaldı, onu çalıştıracak kimse kalmadı. '
      'İnsanlar istifa ettiğinde şirketten değil yöneticiden istifa eder.',

  // --- Onboarding ---
  StringKey.onboardingSkip: 'Atla',
  StringKey.onboardingNext: 'Devam',
  StringKey.onboardingStart: 'Başla',
  StringKey.onboardingStep1Title: 'Tebrikler, CTO oldun',
  StringKey.onboardingStep1Body: 'Küçük bir yazılım girişimine teknik liderlik yapacaksın. Her hafta bir karar vereceksin ve o kararın bedelini de sen ödeyeceksin.',
  StringKey.onboardingStep2Title: 'Teknik borç biriktirir',
  StringKey.onboardingStep2Body: 'Hızlı feature çıkarmak gelir getirir ama teknik borcu büyütür. %100\'e ulaşırsa sunucular yanar. Refactoring sıkıcıdır; sigorta da öyle.',
  StringKey.onboardingStep3Title: 'Hedef: 1.000.000\$',
  StringKey.onboardingStep3Body: 'Değerlemeyi 1 milyon dolara çıkarırsan kazanırsın. Bütçe biterse, borç dolarsa ya da ekip moralini kaybederse kaybedersin. Kolay gelsin.',

  // --- Ortak ---
  StringKey.commonOk: 'Tamam',
  StringKey.commonCancel: 'İptal',
  StringKey.commonClose: 'Kapat',
  StringKey.commonContinue: 'Devam',
  StringKey.commonBack: 'Geri',
  StringKey.commonNewGame: 'Yeni Oyun',
  StringKey.commonNewGameConfirmTitle: 'Yeni oyun başlatılsın mı?',
  StringKey.commonNewGameConfirmBody: 'Mevcut oyun silinecek. Bu işlem geri alınamaz; tıpkı production\'daki o DELETE gibi.',
  StringKey.commonSettings: 'Ayarlar',
  StringKey.commonLanguage: 'Dil',
};
