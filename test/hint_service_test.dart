import 'package:test/test.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/data/game_balance.dart';
import 'package:tech_debt_tycoon/l10n/l10n.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/services/hint_service.dart';

/// Akıllı ipucu algoritması testleri.
void main() {
  final service = HintService(AppStrings.of(AppLanguage.tr));

  /// Hiçbir kuralın tetiklenmediği "sağlıklı" bir durum.
  ///
  /// Kritik eşiklerin hepsinden uzak, nakit akışı pozitif, ekip dolu.
  GameState healthy() => GameState.newGame().copyWith(
    week: 5,
    budget: 40000,
    valuation: 400000,
    weeklyRevenue: 9000,
    techDebt: 20,
    teamMorale: 80,
    team: [kMidHire.copyWith(id: 'm1')],
  );

  group('kritik durumlar (aciliyet 3)', () {
    test('çok yüksek teknik borç her şeyin önüne geçer', () {
      final hint = service.forState(
        healthy().copyWith(techDebt: GameBalance.hintCriticalDebt),
      );
      expect(hint.metric, HintMetric.techDebt);
      expect(hint.priority, 3);
      expect(hint.isUrgent, isTrue);
      expect(hint.suggestedActionId, kRefactorAction.id);
      expect(hint.advice, isNotEmpty);
      expect(hint.reasoning, contains('85'));
    });

    test('çok düşük moral kritik ipucu verir', () {
      final hint = service.forState(
        healthy().copyWith(teamMorale: GameBalance.hintCriticalMorale),
      );
      expect(hint.metric, HintMetric.teamMorale);
      expect(hint.priority, 3);
      expect(hint.suggestedActionId, kTeamMoraleAction.id);
    });

    test('bordroyu ödeyemeyecek bütçe kritik ipucu verir', () {
      // Senior maaşı 2600; 2 haftalık yükün altındaki bütçe kritik.
      final hint = service.forState(
        healthy().copyWith(
          budget: 4000,
          team: [kSeniorHire.copyWith(id: 's1')],
        ),
      );
      expect(hint.metric, HintMetric.budget);
      expect(hint.priority, 3);
    });

    test('kadro yoksa bordro kuralı kritik seviyeye çıkmaz', () {
      // Maaş yükü sıfırken "bordroyu ödeyemezsin" demek anlamsız olurdu.
      // Bütçe yine de düşük olduğu için aciliyet 2'lik uyarı beklenir,
      // ama kritik (3) olmamalı.
      final hint = service.forState(
        healthy().copyWith(budget: 100, team: const []),
      );
      expect(hint.metric, HintMetric.budget);
      expect(hint.priority, 2);
    });

    test('borç ve moral birlikte kritikse borç önce gelir', () {
      final hint = service.forState(
        healthy().copyWith(techDebt: 95, teamMorale: 5),
      );
      expect(hint.metric, HintMetric.techDebt);
    });
  });

  group('önemli durumlar (aciliyet 2)', () {
    test('yüksek teknik borç uyarısı', () {
      final hint = service.forState(healthy().copyWith(techDebt: 65));
      expect(hint.metric, HintMetric.techDebt);
      expect(hint.priority, 2);
      expect(hint.suggestedActionId, kRefactorAction.id);
    });

    test('düşük moral uyarısı', () {
      final hint = service.forState(healthy().copyWith(teamMorale: 25));
      expect(hint.metric, HintMetric.teamMorale);
      expect(hint.priority, 2);
    });

    test('düşük bütçe uyarısı', () {
      final hint = service.forState(
        healthy().copyWith(budget: 4000, team: const []),
      );
      expect(hint.metric, HintMetric.budget);
      expect(hint.priority, 2);
    });
  });

  group('normal durumlar (aciliyet 1)', () {
    test('negatif nakit akışı uyarısı', () {
      final hint = service.forState(
        healthy().copyWith(
          weeklyRevenue: 0,
          team: [kSeniorHire.copyWith(id: 's1')],
        ),
      );
      expect(hint.metric, HintMetric.revenue);
      expect(hint.priority, 1);
    });

    test('ekip boş ve bütçe uygunsa işe alım önerir', () {
      final hint = service.forState(healthy().copyWith(team: const []));
      expect(hint.metric, HintMetric.team);
      expect(hint.suggestedActionId, kHireAction.id);
    });

    test('ekip boş ama bütçe yetersizse işe alım önermez', () {
      final hint = service.forState(
        healthy().copyWith(
          team: const [],
          budget: GameBalance.hintHireBudgetFloor - 1,
        ),
      );
      expect(hint.metric, isNot(HintMetric.team));
    });

    test('ilerleme yavaşsa büyüme önerir', () {
      final hint = service.forState(
        healthy().copyWith(
          week: GameBalance.hintSlowGrowthAfterWeek + 1,
          valuation: 60000,
        ),
      );
      expect(hint.metric, HintMetric.valuation);
      expect(hint.suggestedActionId, kShipFeatureAction.id);
      expect(hint.reasoning, contains('11'));
    });

    test('erken haftalarda yavaş ilerleme uyarısı verilmez', () {
      final hint = service.forState(
        healthy().copyWith(week: 3, valuation: 60000),
      );
      expect(hint.priority, 0);
    });
  });

  group('her şey yolunda (aciliyet 0)', () {
    test('sağlıklı durumda bilgilendirici ipucu döner', () {
      final hint = service.forState(healthy());
      expect(hint.priority, 0);
      expect(hint.isUrgent, isFalse);
      expect(hint.advice, isNotEmpty);
      expect(hint.reasoning, isNotEmpty);
    });
  });

  group('genel güvenceler', () {
    test('hiçbir durumda boş metin ya da eksik çeviri dönmez', () {
      // Metrik uzayını tarayıp her kombinasyonda sağlam sonuç bekliyoruz.
      for (final debt in [0, 30, 60, 85, 100]) {
        for (final morale in [0, 15, 30, 60, 100]) {
          for (final budget in [0, 3000, 15000, 60000]) {
            final hint = service.forState(
              GameState.newGame().copyWith(
                week: 12,
                techDebt: debt,
                teamMorale: morale,
                budget: budget,
              ),
            );
            final tag = 'borç $debt, moral $morale, bütçe $budget';
            expect(hint.advice.trim(), isNotEmpty, reason: tag);
            expect(hint.reasoning.trim(), isNotEmpty, reason: tag);
            expect(hint.advice, isNot(contains('⟨')), reason: tag);
            expect(hint.reasoning, isNot(contains('⟨')), reason: tag);
            expect(hint.reasoning, isNot(contains('{')), reason: tag);
            expect(hint.priority, inInclusiveRange(0, 3), reason: tag);
          }
        }
      }
    });

    test('önerilen aksiyon her zaman gerçek bir aksiyondur', () {
      for (final debt in [10, 70, 90]) {
        for (final morale in [10, 50, 90]) {
          final hint = service.forState(
            GameState.newGame().copyWith(techDebt: debt, teamMorale: morale),
          );
          final actionId = hint.suggestedActionId;
          if (actionId == null) continue;
          expect(actionById(actionId), isNotNull, reason: actionId);
        }
      }
    });
  });
}
