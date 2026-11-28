import 'dart:async';
import 'dart:math';

import '../data/game_balance.dart';

/// Sahte reklamın sonucu.
enum AdOutcome {
  /// Reklam sonuna kadar izlendi, ödül verilmeli.
  rewarded,

  /// Reklam yüklenemedi (envanter yok, ağ yok). Ödül verilmez.
  failed,

  /// Oyuncu reklamı yarıda kesti. Ödül verilmez.
  cancelled,
}

/// Ödüllü reklam arayüzü.
///
/// Aşama 1-3'te gerçek bir reklam ağı **yok**: oyun tamamen çevrimdışı
/// çalışıyor ve mağaza yayınına kadar SDK bağlamanın anlamı yok. Bu arayüz
/// ileride gerçek bir ağ (AdMob vb.) takılacağı noktayı şimdiden
/// işaretliyor; UI yalnızca bu arayüzü tanıyor.
abstract interface class AdService {
  /// Ödüllü reklamı gösterir ve sonucu döner.
  ///
  /// [onCancelled] bir future verirse ve oyuncu bekleme sırasında iptal
  /// ederse [AdOutcome.cancelled] döner.
  Future<AdOutcome> showRewardedAd({Future<void>? onCancelled});

  /// Reklamın ne kadar süreceği. UI geri sayım göstermek için kullanır.
  Duration get adDuration;
}

/// Gerçek reklam ağı yerine geçen sahte servis.
///
/// Davranışı bilinçli olarak "gerçekçi": belirli bir süre bekler ve
/// ara sıra başarısız olur. Böylece Aşama 3'teki UI hem ödül hem hata
/// yolunu gerçekten gösterebilir.
class FakeAdService implements AdService {
  FakeAdService({
    Random? random,
    Duration? duration,
    double? failureChance,
    Future<void> Function(Duration)? delay,
  }) : _random = random ?? Random(),
       _duration = duration ?? GameBalance.fakeAdDuration,
       _failureChance = failureChance ?? GameBalance.fakeAdFailureChance,
       _delay = delay ?? Future<void>.delayed;

  final Random _random;
  final Duration _duration;
  final double _failureChance;

  /// Bekleme fonksiyonu. Testlerde anında dönen bir sahte ile değiştirilir,
  /// böylece test gerçekten 3 saniye beklemez.
  final Future<void> Function(Duration) _delay;

  @override
  Duration get adDuration => _duration;

  @override
  Future<AdOutcome> showRewardedAd({Future<void>? onCancelled}) async {
    // Reklam ağı envanter bulamadıysa beklemeye bile gerek yok.
    if (_random.nextDouble() < _failureChance) {
      return AdOutcome.failed;
    }

    final watching = _delay(_duration).then((_) => AdOutcome.rewarded);
    if (onCancelled == null) return watching;

    // Hangisi önce biterse: reklam tamamlanır ya da oyuncu iptal eder.
    return Future.any([watching, onCancelled.then((_) => AdOutcome.cancelled)]);
  }
}

/// Testler için her zaman aynı sonucu dönen servis.
class StubAdService implements AdService {
  const StubAdService(this.outcome);

  /// Her çağrıda dönecek sonuç.
  final AdOutcome outcome;

  @override
  Duration get adDuration => Duration.zero;

  @override
  Future<AdOutcome> showRewardedAd({Future<void>? onCancelled}) async =>
      outcome;
}
