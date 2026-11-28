/// Kullanıcıya görünen bütün sabit metinlerin anahtarları.
///
/// Kural: widget'ların içine düz metin yazılmaz. Her metin burada bir anahtar
/// alır ve dil dosyalarından (`strings_tr.dart` vb.) okunur. Bir anahtarın
/// çevirisi eksikse `test/l10n_test.dart` bunu yakalar.
///
/// Karakter replikleri ve olay kartı metinleri hacimli olduğu için burada
/// değil `lib/data/` altında durur; onlar da aynı mantıkla dile göre
/// değiştirilebilecek şekilde tasarlandı (bkz. `lib/data/game_content.dart`).
enum StringKey {
  // --- Uygulama genel ---
  appTitle,
  appTagline,

  // --- Alt navigasyon ---
  navOffice,
  navTeam,
  navGlossary,
  navLog,

  // --- Metrik etiketleri ---
  metricBudget,
  metricValuation,
  metricWeeklyRevenue,

  /// Dar alanlarda (metrik kutusu) kullanılan kısa biçim.
  metricWeeklyRevenueShort,
  metricTechDebt,
  metricTeamMorale,
  metricWeek,
  metricTeamSize,
  metricNetCashFlow,

  // --- Ofis ekranı ---
  officeTitle,
  officeWeekLabel,
  officeChooseAction,
  officeActionsSectionTitle,
  officeNextWeek,
  officeUnicornProgress,
  officeAdvisorSectionTitle,

  // --- İpucu / danışman ---
  hintSheetTitle,
  hintAdviceLabel,
  hintReasonLabel,
  hintMetricLabel,
  hintFreeRemaining,
  hintNoFreeLeft,
  hintWatchAdButton,
  hintAskButton,
  hintEverythingFine,

  // --- İpucu metinleri (akıllı ipucu algoritması) ---
  // Her kural için bir tavsiye (advice) ve bir gerekçe (reason) anahtarı.
  hintDebtCriticalAdvice,
  hintDebtCriticalReason,
  hintDebtHighAdvice,
  hintDebtHighReason,
  hintMoraleCriticalAdvice,
  hintMoraleCriticalReason,
  hintMoraleLowAdvice,
  hintMoraleLowReason,
  hintBudgetCriticalAdvice,
  hintBudgetCriticalReason,
  hintBudgetLowAdvice,
  hintBudgetLowReason,
  hintCashFlowNegativeAdvice,
  hintCashFlowNegativeReason,
  hintHireTeamAdvice,
  hintHireTeamReason,
  hintSlowGrowthAdvice,
  hintSlowGrowthReason,
  hintAllGoodAdvice,
  hintAllGoodReason,

  // --- Sahte reklam ---
  adSheetTitle,
  adLoading,
  adRewardGranted,
  adFailed,
  adCancel,

  // --- Sprint sonucu ---
  sprintResultTitle,
  sprintResultActionLabel,
  sprintResultRevenue,
  sprintResultValuationGrowth,
  sprintResultActionEffect,
  sprintResultTeamEffect,
  sprintResultDebtDrift,
  sprintResultHired,
  sprintResultEventIncoming,
  sprintResultCalmWeek,
  sprintResultContinue,

  // --- Olay kartları ---
  eventSheetTitle,
  eventChooseOption,
  eventOutcomeTitle,
  eventContinueButton,

  // --- Ekip ekranı ---
  teamTitle,
  teamEmptyMessage,
  teamRosterSectionTitle,
  teamHireSectionTitle,
  teamHireButton,
  teamSalaryLabel,
  teamRevenueLabel,
  teamDebtEffectLabel,
  teamMoraleEffectLabel,
  teamNetValueLabel,
  teamPassiveEffectLabel,
  teamInsufficientBudget,
  teamHiredMessage,

  // --- Çalışan seviyeleri ---
  levelJunior,
  levelMid,
  levelSenior,
  levelDevops,

  // --- Sözlük ekranı ---
  glossaryTitle,
  glossarySearchHint,
  glossaryNoResults,
  glossaryDefinitionLabel,
  glossaryRealLifeLabel,
  glossaryGameEffectLabel,
  glossaryCategoryAll,
  glossaryCategoryEngineering,
  glossaryCategoryProcess,
  glossaryCategoryInfrastructure,
  glossaryCategoryQuality,
  glossaryCategoryBusiness,

  // --- Log & Kariyer ekranı ---
  logTitle,
  logEmptyMessage,
  logHistorySectionTitle,
  logStatsSectionTitle,
  logBestValuation,
  logTotalGames,
  logTotalWins,
  logLongestRun,
  logRecordWeeks,
  logRecordCrises,
  logOutcomeWin,
  logOutcomeLoss,

  // --- Oyun sonu ---
  gameOverWonTitle,
  gameOverWonSubtitle,
  gameOverLostTitle,
  lossReasonBankruptcy,
  lossReasonServerMeltdown,
  lossReasonMassResignation,
  gameOverWeeksLabel,
  gameOverValuationLabel,
  gameOverCrisesLabel,
  gameOverCtoNoteLabel,
  gameOverRestartButton,

  // --- CTO notları (oyun sonu değerlendirmesi) ---
  ctoNoteWonClean,
  ctoNoteWonWithDebt,
  ctoNoteLostBankruptcy,
  ctoNoteLostMeltdown,
  ctoNoteLostResignation,

  // --- Onboarding ---
  onboardingSkip,
  onboardingNext,
  onboardingStart,
  onboardingStep1Title,
  onboardingStep1Body,
  onboardingStep2Title,
  onboardingStep2Body,
  onboardingStep3Title,
  onboardingStep3Body,

  // --- Ortak ---
  commonOk,
  commonCancel,
  commonClose,
  commonContinue,
  commonBack,
  commonNewGame,
  commonNewGameConfirmTitle,
  commonNewGameConfirmBody,
  commonSettings,
  commonLanguage,
}
