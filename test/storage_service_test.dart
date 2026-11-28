import 'package:test/test.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/l10n/l10n.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/services/storage_service.dart';

/// Kalıcı kayıt arayüzü testleri.
///
/// Hive uygulaması Flutter bağlamı (ve gerçek dosya sistemi) gerektirdiği
/// için burada bellek uygulaması test ediliyor. İkisi aynı arayüzü
/// uyguladığından sözleşme testleri ikisi için de geçerli.
void main() {
  group('InMemoryStorageService', () {
    test('başlangıçta kayıt yok', () async {
      final storage = InMemoryStorageService();
      await storage.init();

      expect(storage.loadGameState(), isNull);
      expect(storage.loadRecords(), isEmpty);
      expect(storage.onboardingCompleted, isFalse);
      expect(storage.language, AppLanguage.fallback);
    });

    test('kaydedilen oyun aynen geri okunur', () async {
      final storage = InMemoryStorageService();
      await storage.init();

      final state = GameState.newGame().copyWith(
        week: 14,
        budget: 31200,
        techDebt: 55,
        team: [kSeniorHire.copyWith(id: 's1')],
        pendingEventId: 'event_cloud_bill',
        seenEventIds: const ['event_friday_deploy'],
      );
      await storage.saveGameState(state);

      expect(storage.loadGameState(), state);
    });

    test('kayıt silinince null döner', () async {
      final storage = InMemoryStorageService();
      await storage.init();
      await storage.saveGameState(GameState.newGame());
      await storage.clearGameState();

      expect(storage.loadGameState(), isNull);
    });

    test('kayıt sayacı yazma sayısını takip eder', () async {
      final storage = InMemoryStorageService();
      await storage.init();

      await storage.saveGameState(GameState.newGame());
      await storage.saveGameState(GameState.newGame().copyWith(week: 2));

      expect(storage.saveCount, 2);
    });

    test('geçmiş kayıtlar en yeniden en eskiye sıralanır', () async {
      final storage = InMemoryStorageService();
      await storage.init();

      await storage.addRecord(_record('eski', DateTime.utc(2026, 1, 1)));
      await storage.addRecord(_record('yeni', DateTime.utc(2026, 6, 1)));
      await storage.addRecord(_record('orta', DateTime.utc(2026, 3, 1)));

      expect(storage.loadRecords().map((r) => r.id).toList(), [
        'yeni',
        'orta',
        'eski',
      ]);
    });

    test('dönen geçmiş listesi değiştirilemez', () async {
      final storage = InMemoryStorageService();
      await storage.init();
      await storage.addRecord(_record('a', DateTime.utc(2026)));

      expect(
        () => storage.loadRecords().add(_record('b', DateTime.utc(2026))),
        throwsUnsupportedError,
      );
    });

    test('onboarding ve dil ayarları kalıcı', () async {
      final storage = InMemoryStorageService();
      await storage.init();

      await storage.setOnboardingCompleted(true);
      await storage.setLanguage(AppLanguage.en);

      expect(storage.onboardingCompleted, isTrue);
      expect(storage.language, AppLanguage.en);
    });

    test('geçmiş temizlenebilir', () async {
      final storage = InMemoryStorageService();
      await storage.init();
      await storage.addRecord(_record('a', DateTime.utc(2026)));
      await storage.clearRecords();

      expect(storage.loadRecords(), isEmpty);
    });

    test('başlangıç değerleriyle kurulabilir', () async {
      final seeded = InMemoryStorageService(
        gameState: GameState.newGame().copyWith(week: 9),
        onboardingCompleted: true,
        language: AppLanguage.tr,
      );
      await seeded.init();

      expect(seeded.loadGameState()?.week, 9);
      expect(seeded.onboardingCompleted, isTrue);
    });
  });

  group('StorageKeys', () {
    test('anahtarlar boş değil ve tekil', () {
      const keys = [
        StorageKeys.boxName,
        StorageKeys.gameState,
        StorageKeys.records,
        StorageKeys.onboardingCompleted,
        StorageKeys.language,
      ];
      expect(keys.every((k) => k.isNotEmpty), isTrue);
      expect(keys.toSet(), hasLength(keys.length));
    });
  });
}

GameRecord _record(String id, DateTime playedAt) => GameRecord(
  id: id,
  playedAt: playedAt,
  weeksSurvived: 10,
  finalValuation: 120000,
  resolvedCrises: 2,
  outcome: GameStatus.lost,
  lossReason: LossReason.bankruptcy,
  ctoNote: 'lost_bankruptcy',
);
