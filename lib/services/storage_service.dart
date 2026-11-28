// Bu dosyada `prefer_initializing_formals` kapali: alanlar gizli (_ ile
// baslıyor) ve Dart gizli adli adlandirilmis parametreye izin vermiyor
// (`this._x` cagrilabilir bir parametre uretmiyor). Lint'in onerisi burada
// derlenmeyen kod uretir.
// ignore_for_file: prefer_initializing_formals

import '../l10n/app_language.dart';
import '../models/models.dart';

/// Kalıcı kayıt arayüzü.
///
/// Soyut tutulmasının iki nedeni var:
/// 1. Testler Hive açmak zorunda kalmadan [InMemoryStorageService] kullanır.
/// 2. İleride kayıt yeri değişirse (ör. bulut yedekleme) yalnızca bu
///    arayüzün yeni bir uygulaması yazılır; oyun kodu değişmez.
///
/// Okuma işlemleri senkron: oyun açılırken kayıt bir kez belleğe alınır,
/// sonrasında UI beklemek zorunda kalmaz. Yazma işlemleri asenkron.
abstract interface class StorageService {
  /// Depolamayı hazırlar. Diğer çağrılardan önce bir kez beklenmeli.
  Future<void> init();

  /// Devam eden oyunun durumu; kayıt yoksa `null`.
  GameState? loadGameState();

  /// Devam eden oyunu kaydeder (otomatik kayıt).
  Future<void> saveGameState(GameState state);

  /// Devam eden oyunun kaydını siler (yeni oyun başlatırken).
  Future<void> clearGameState();

  /// Tamamlanmış oyun kayıtları, en yeniden en eskiye sıralı.
  List<GameRecord> loadRecords();

  /// Tamamlanmış bir oyunu geçmişe ekler.
  Future<void> addRecord(GameRecord record);

  /// Bütün geçmişi siler.
  Future<void> clearRecords();

  /// Onboarding daha önce tamamlandı mı?
  bool get onboardingCompleted;

  /// Onboarding durumunu kaydeder.
  Future<void> setOnboardingCompleted(bool value);

  /// Seçili dil.
  AppLanguage get language;

  /// Dil seçimini kaydeder.
  Future<void> setLanguage(AppLanguage language);

  /// Kaynakları kapatır.
  Future<void> close();
}

/// Depolamada kullanılan anahtarlar.
///
/// Tek yerde durması şart: yazım hatası sessizce veri kaybına yol açar.
abstract final class StorageKeys {
  /// Hive kutusunun adı.
  static const String boxName = 'tech_debt_tycoon';

  /// Devam eden oyunun JSON'u.
  static const String gameState = 'gameState';

  /// Tamamlanmış oyunların JSON listesi.
  static const String records = 'records';

  /// Onboarding tamamlandı mı (bool).
  static const String onboardingCompleted = 'onboardingCompleted';

  /// Seçili dilin ISO kodu (String).
  static const String language = 'language';
}

/// Bellekte tutan, kalıcı olmayan uygulama.
///
/// Testlerde ve Hive'ın açılamadığı durumlarda yedek olarak kullanılır:
/// oyun oynanabilir kalır, yalnızca uygulama kapanınca kayıt gider.
class InMemoryStorageService implements StorageService {
  InMemoryStorageService({
    GameState? gameState,
    List<GameRecord>? records,
    bool onboardingCompleted = false,
    AppLanguage language = AppLanguage.fallback,
  }) : _gameState = gameState,
       _records = [...?records],
       _onboardingCompleted = onboardingCompleted,
       _language = language;

  GameState? _gameState;
  final List<GameRecord> _records;
  bool _onboardingCompleted;
  AppLanguage _language;

  /// Kaç kez kayıt yazıldığı. Otomatik kaydın gerçekten çalıştığını
  /// doğrulamak için testlerde kullanılır.
  int saveCount = 0;

  @override
  Future<void> init() async {}

  @override
  GameState? loadGameState() => _gameState;

  @override
  Future<void> saveGameState(GameState state) async {
    _gameState = state;
    saveCount++;
  }

  @override
  Future<void> clearGameState() async {
    _gameState = null;
  }

  @override
  List<GameRecord> loadRecords() => List.unmodifiable(_records);

  @override
  Future<void> addRecord(GameRecord record) async {
    _records
      ..add(record)
      ..sort((a, b) => b.playedAt.compareTo(a.playedAt));
  }

  @override
  Future<void> clearRecords() async => _records.clear();

  @override
  bool get onboardingCompleted => _onboardingCompleted;

  @override
  Future<void> setOnboardingCompleted(bool value) async {
    _onboardingCompleted = value;
  }

  @override
  AppLanguage get language => _language;

  @override
  Future<void> setLanguage(AppLanguage language) async {
    _language = language;
  }

  @override
  Future<void> close() async {}
}
