import 'dart:async';
import 'dart:math';

import 'package:test/test.dart';

import 'package:tech_debt_tycoon/services/ad_service.dart';

/// Sahte reklam servisi testleri.
///
/// Gerçek bekleme yapılmaması için [FakeAdService]'e anında dönen bir
/// bekleme fonksiyonu veriliyor; testler milisaniyeler içinde koşuyor.
void main() {
  /// Beklemeyi atlayan sahte gecikme.
  Future<void> noDelay(Duration _) => Future<void>.value();

  group('FakeAdService', () {
    test('reklam tamamlanınca ödül verilir', () async {
      final service = FakeAdService(
        random: _FixedRandom(0.99),
        failureChance: 0.1,
        delay: noDelay,
      );

      expect(await service.showRewardedAd(), AdOutcome.rewarded);
    });

    test('envanter yoksa başarısız olur', () async {
      final service = FakeAdService(
        random: _FixedRandom(0.0),
        failureChance: 0.1,
        delay: noDelay,
      );

      expect(await service.showRewardedAd(), AdOutcome.failed);
    });

    test('başarısızlık olasılığı sıfırsa hiç başarısız olmaz', () async {
      final service = FakeAdService(
        random: Random(7),
        failureChance: 0,
        delay: noDelay,
      );

      for (var i = 0; i < 20; i++) {
        expect(await service.showRewardedAd(), AdOutcome.rewarded);
      }
    });

    test('oyuncu iptal ederse ödül verilmez', () async {
      // Reklam hiç bitmesin; iptal hemen gelsin.
      final service = FakeAdService(
        random: _FixedRandom(0.99),
        failureChance: 0.1,
        delay: (_) => Completer<void>().future,
      );

      expect(
        await service.showRewardedAd(onCancelled: Future<void>.value()),
        AdOutcome.cancelled,
      );
    });

    test('iptal gelmezse reklam normal tamamlanır', () async {
      final service = FakeAdService(
        random: _FixedRandom(0.99),
        failureChance: 0.1,
        delay: noDelay,
      );

      expect(
        await service.showRewardedAd(onCancelled: Completer<void>().future),
        AdOutcome.rewarded,
      );
    });

    test('reklam süresi dışarıya bildirilir', () {
      const duration = Duration(seconds: 5);
      final service = FakeAdService(duration: duration, delay: noDelay);
      expect(service.adDuration, duration);
    });
  });

  group('StubAdService', () {
    test('her zaman verilen sonucu döner', () async {
      for (final outcome in AdOutcome.values) {
        final service = StubAdService(outcome);
        expect(await service.showRewardedAd(), outcome);
      }
    });
  });
}

/// `nextDouble` her zaman aynı değeri döner.
class _FixedRandom implements Random {
  _FixedRandom(this.value);

  final double value;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => 0;

  @override
  bool nextBool() => value < 0.5;
}
