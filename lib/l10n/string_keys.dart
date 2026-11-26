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

  // --- Sahte reklam ---
  adSheetTitle,
  adLoading,
  adRewardGranted,
  adFailed,
  adCancel,

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
