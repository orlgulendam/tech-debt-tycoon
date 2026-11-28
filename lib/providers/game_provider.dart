import 'package:riverpod/riverpod.dart';

import '../data/game_balance.dart';
import '../models/models.dart';
import '../services/ad_service.dart';
import '../services/game_engine.dart';
import 'app_providers.dart';

/// Oyunun tek doğruluk kaynağı.
///
/// Durumu asla yerinde değiştirmez: her işlem [GameEngine]'den yeni bir
/// [GameState] alır ve atar. Her atamadan sonra **otomatik kayıt** yapılır,
/// böylece oyuncu uygulamayı kapatıp açtığında kaldığı haftadan devam eder.
final gameControllerProvider = NotifierProvider<GameController, GameState>(
  GameController.new,
);

/// Oyun akışını yürüten controller.
class GameController extends Notifier<GameState> {
  @override
  GameState build() {
    // Kayıtlı oyun varsa oradan devam et, yoksa yeni oyun başlat.
    return ref.read(storageServiceProvider).loadGameState() ??
        GameState.newGame();
  }

  /// Son oynanan sprint'in sonucu.
  ///
  /// UI "bu hafta ne oldu" özetini bundan çizer. Yeni oyunda ya da henüz
  /// sprint oynanmadığında `null`.
  SprintResult? get lastSprint => _lastSprint;
  SprintResult? _lastSprint;

  /// Son çözülen olayın sonucu.
  EventResolution? get lastEventResolution => _lastEventResolution;
  EventResolution? _lastEventResolution;

  /// Durumu atar ve kayda yazar.
  ///
  /// Kayıt beklenmez (`await` edilmez): UI bir sonraki kareyi beklemesin.
  /// Kaydın kendisi tek küçük bir JSON olduğu için sıraya girmesi sorun değil.
  void _commit(GameState next) {
    state = next;
    ref.read(storageServiceProvider).saveGameState(next);
  }

  /// Karar bekleyen olay kartı (varsa).
  ///
  /// Kart kimliği durumda tutulduğu için uygulama kapatılıp açılsa bile
  /// aynı karar ekranı geri gelir.
  EventCard? get pendingEvent {
    final id = state.pendingEventId;
    if (id == null) return null;
    return eventCardByIdIn(ref.read(contentProvider).events, id);
  }

  /// Bir sprint oynar.
  ///
  /// [action] işe alım aksiyonuysa [hire] zorunludur. Bütçe yetmiyorsa ya da
  /// karar bekleyen bir olay varsa hiçbir şey yapmaz ve `null` döner; UI
  /// bu durumları zaten butonu kilitleyerek engelliyor, ama durum
  /// yarışlarına karşı sessiz ve güvenli davranıyoruz.
  SprintResult? playSprint(GameAction action, {Employee? hire}) {
    if (!state.isPlaying || state.hasPendingEvent) return null;
    if (action.requiresHireSelection && hire == null) return null;
    if (!GameEngine.canAfford(state, action, hire: hire)) return null;

    final result = GameEngine.playSprint(
      state,
      action,
      hire: hire,
      random: ref.read(randomProvider),
    );

    _lastSprint = result;
    _lastEventResolution = null;
    _commit(result.state);

    // Oyun bu sprint'te bittiyse geçmişe yaz.
    if (result.isGameOver) _archive(result.state);

    return result;
  }

  /// Karar bekleyen olay kartını verilen seçenekle kapatır.
  ///
  /// Bekleyen olay yoksa ya da seçenek o karta ait değilse `null` döner.
  EventResolution? resolveEvent(EventChoice choice) {
    final card = pendingEvent;
    if (card == null) return null;
    if (card.choiceById(choice.id) == null) return null;

    final resolution = GameEngine.resolveEvent(state, card, choice);
    _lastEventResolution = resolution;
    _commit(resolution.state);

    if (resolution.isGameOver) _archive(resolution.state);

    return resolution;
  }

  /// Ücretsiz bir ipucu hakkı harcar.
  ///
  /// Hak kalmadıysa `false` döner; UI o zaman reklam teklif eder.
  bool useHint() {
    if (!GameEngine.canUseHint(state)) return false;
    _commit(state.copyWith(usedFreeHints: state.usedFreeHints + 1));
    return true;
  }

  /// Reklam izleyip danışman tutar ve ipucu hakkı kazanır.
  ///
  /// Reklam başarısız olursa ya da oyuncu iptal ederse hak verilmez.
  /// Dönen değer ödülün verilip verilmediğidir.
  Future<AdOutcome> watchAdForHint({Future<void>? onCancelled}) async {
    final outcome = await ref
        .read(adServiceProvider)
        .showRewardedAd(onCancelled: onCancelled);

    if (outcome == AdOutcome.rewarded) {
      _commit(state.copyWith(hiredConsultants: state.hiredConsultants + 1));
    }
    return outcome;
  }

  /// Oyunu sıfırdan başlatır.
  ///
  /// Devam eden oyun bitmemişse geçmişe **yazılmaz**: yarıda bırakılan oyun
  /// bir sonuç değildir.
  void startNewGame() {
    _lastSprint = null;
    _lastEventResolution = null;
    _commit(GameState.newGame());
  }

  /// Bitmiş oyunu kariyer geçmişine ekler.
  void _archive(GameState finished) {
    if (finished.isPlaying) return;

    final record = GameRecord.fromGameState(
      finished,
      ctoNote: _ctoNoteFor(finished),
      playedAt: DateTime.now(),
    );
    final storage = ref.read(storageServiceProvider);
    storage.addRecord(record);
    // Biten oyunun "devam eden oyun" kaydı kalmasın.
    storage.clearGameState();
    ref.invalidate(gameRecordsProvider);
  }

  /// Oyun sonu CTO notunun anahtarını seçer.
  ///
  /// Not metninin kendisi `lib/l10n/` içinde; burada yalnızca hangi notun
  /// uygun olduğuna karar veriyoruz ve anahtarı kaydediyoruz. Böylece
  /// geçmiş kayıtlar dil değişse de doğru dilde gösterilebilir.
  String _ctoNoteFor(GameState finished) {
    if (finished.status == GameStatus.won) {
      return finished.techDebt >= GameBalance.debtRevenuePenaltyThreshold
          ? CtoNoteKeys.wonWithDebt
          : CtoNoteKeys.wonClean;
    }
    return switch (finished.lossReason) {
      LossReason.bankruptcy => CtoNoteKeys.lostBankruptcy,
      LossReason.serverMeltdown => CtoNoteKeys.lostMeltdown,
      LossReason.massResignation => CtoNoteKeys.lostResignation,
      null => CtoNoteKeys.lostBankruptcy,
    };
  }
}

/// CTO notu anahtarları.
///
/// [GameRecord.ctoNote] alanında düz metin değil bu anahtarlardan biri
/// saklanır; UI metni `lib/l10n/` üzerinden çözer. Kayıtlar böylece dilden
/// bağımsız kalıyor.
abstract final class CtoNoteKeys {
  static const String wonClean = 'won_clean';
  static const String wonWithDebt = 'won_with_debt';
  static const String lostBankruptcy = 'lost_bankruptcy';
  static const String lostMeltdown = 'lost_meltdown';
  static const String lostResignation = 'lost_resignation';
}

/// Kariyer geçmişi: tamamlanmış oyunlar, en yeniden en eskiye.
final gameRecordsProvider = Provider<List<GameRecord>>((ref) {
  return ref.read(storageServiceProvider).loadRecords();
});

/// Geçmişten türetilen kariyer özeti.
final careerStatsProvider = Provider<CareerStats>((ref) {
  return CareerStats.fromRecords(ref.watch(gameRecordsProvider));
});

/// O anki duruma göre en acil ipucu.
final currentHintProvider = Provider<HintResult>((ref) {
  final hintService = ref.watch(hintServiceProvider);
  return hintService.forState(ref.watch(gameControllerProvider));
});

/// Kalan ipucu hakkı.
final remainingHintsProvider = Provider<int>((ref) {
  return GameEngine.remainingHints(ref.watch(gameControllerProvider));
});

/// Verilen listede kimliğe göre olay kartı arar.
///
/// `lib/data/events.dart` içindeki genel arama yerine bunu kullanıyoruz ki
/// kart havuzu dile göre değiştiğinde doğru listede arama yapılsın.
EventCard? eventCardByIdIn(List<EventCard> cards, String id) {
  for (final card in cards) {
    if (card.id == id) return card;
  }
  return null;
}
