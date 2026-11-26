import 'package:test/test.dart';

import 'package:tech_debt_tycoon/models/models.dart';

/// Model katmanı testleri: `copyWith`, serileştirme ve türetilmiş değerler.
///
/// Modeller saf Dart olduğu için bu dosya Flutter motoru olmadan `dart test`
/// ile de koşar.
void main() {
  group('GameEffect', () {
    test('toplama iki efektin bütün alanlarını toplar', () {
      const a = GameEffect(
        budgetDelta: 100,
        revenueDelta: 10,
        valuationDelta: 1000,
        techDebtDelta: 5,
        moraleDelta: -2,
      );
      const b = GameEffect(
        budgetDelta: -40,
        revenueDelta: 5,
        valuationDelta: 500,
        techDebtDelta: -3,
        moraleDelta: 4,
      );

      final sum = a + b;

      expect(sum.budgetDelta, 60);
      expect(sum.revenueDelta, 15);
      expect(sum.valuationDelta, 1500);
      expect(sum.techDebtDelta, 2);
      expect(sum.moraleDelta, 2);
    });

    test('nötr efekt toplamayı değiştirmez', () {
      const effect = GameEffect(budgetDelta: 250, techDebtDelta: 7);
      expect(effect + GameEffect.none, effect);
      expect(GameEffect.none.isEmpty, isTrue);
      expect(effect.isEmpty, isFalse);
    });

    test('scaled bütün alanları ölçekler ve yuvarlar', () {
      const effect = GameEffect(budgetDelta: 100, techDebtDelta: 5);
      final scaled = effect.scaled(1.5);
      expect(scaled.budgetDelta, 150);
      expect(scaled.techDebtDelta, 8); // 7.5 -> 8
    });

    test('copyWith yalnızca verilen alanı değiştirir', () {
      const effect = GameEffect(budgetDelta: 100, moraleDelta: 3);
      final updated = effect.copyWith(moraleDelta: 9);
      expect(updated.budgetDelta, 100);
      expect(updated.moraleDelta, 9);
    });

    test('JSON gidiş-dönüşü değeri korur', () {
      const effect = GameEffect(
        budgetDelta: -1234,
        revenueDelta: 567,
        valuationDelta: 89000,
        techDebtDelta: -12,
        moraleDelta: 15,
      );
      expect(GameEffect.fromJson(effect.toJson()), effect);
    });
  });

  group('Employee', () {
    const employee = Employee(
      id: 'e1',
      name: 'Test Geliştirici',
      title: 'Senior Developer',
      level: EmployeeLevel.senior,
      weeklySalary: 2600,
      revenueContribution: 2000,
      techDebtEffect: -2,
      moraleEffect: 2,
      iconId: 'senior',
    );

    test('pasif efekt maaşı gider, gelir katkısını gelir olarak yazar', () {
      final effect = employee.passiveEffect;
      expect(effect.budgetDelta, -2600);
      expect(effect.revenueDelta, 2000);
      expect(effect.techDebtDelta, -2);
      expect(effect.moraleDelta, 2);
    });

    test('netWeeklyValue gelir eksi maaştır', () {
      expect(employee.netWeeklyValue, -600);
    });

    test('copyWith kimliği değiştirip diğer alanları korur', () {
      final hired = employee.copyWith(id: 'e1#3');
      expect(hired.id, 'e1#3');
      expect(hired.name, employee.name);
      expect(hired.weeklySalary, employee.weeklySalary);
    });

    test('JSON gidiş-dönüşü değeri korur', () {
      expect(Employee.fromJson(employee.toJson()), employee);
    });

    test('bilinmeyen seviye adı güvenli varsayılana düşer', () {
      final json = employee.toJson()..['level'] = 'archmage';
      expect(Employee.fromJson(json).level, EmployeeLevel.mid);
    });
  });

  group('GameState', () {
    test('newGame belirlenen başlangıç değerleriyle gelir', () {
      final state = GameState.newGame();
      expect(state.week, 1);
      expect(state.budget, 15000);
      expect(state.valuation, 50000);
      expect(state.techDebt, GameState.initialTechDebt);
      expect(state.teamMorale, GameState.initialTeamMorale);
      expect(state.status, GameStatus.playing);
      expect(state.lossReason, isNull);
      expect(state.team, isEmpty);
    });

    test('kazanma eşiği 1.000.000 dolardır', () {
      expect(GameState.winValuation, 1000000);
    });

    test('türetilmiş ekip değerleri doğru hesaplanır', () {
      final state = GameState.newGame().copyWith(
        team: const [
          Employee(
            id: 'a',
            name: 'A',
            title: 'Junior Developer',
            level: EmployeeLevel.junior,
            weeklySalary: 800,
            revenueContribution: 450,
            techDebtEffect: 3,
            moraleEffect: 1,
            iconId: 'junior',
          ),
          Employee(
            id: 'b',
            name: 'B',
            title: 'DevOps Engineer',
            level: EmployeeLevel.devops,
            weeklySalary: 2300,
            revenueContribution: 1400,
            techDebtEffect: -4,
            moraleEffect: 1,
            iconId: 'devops',
          ),
        ],
      );

      expect(state.totalSalaries, 3100);
      expect(state.totalTeamRevenue, 1850);
      // 2000 (temel gelir) + 1850 (ekip) - 3100 (maaşlar)
      expect(state.netWeeklyCashFlow, 750);
      expect(state.teamPassiveEffect.techDebtDelta, -1);
      expect(state.teamPassiveEffect.moraleDelta, 2);
      expect(state.hasTeam, isTrue);
    });

    test('clamped yüzdeleri 0-100 aralığına çeker', () {
      final overflowed = GameState.newGame().copyWith(
        techDebt: 140,
        teamMorale: -30,
      );
      final clamped = overflowed.clamped();
      expect(clamped.techDebt, 100);
      expect(clamped.teamMorale, 0);
    });

    test('kritik eşik bayrakları eşiklerle tutarlı', () {
      final base = GameState.newGame();
      expect(base.isTechDebtCritical, isFalse);
      expect(base.copyWith(techDebt: 60).isTechDebtCritical, isTrue);
      expect(base.copyWith(teamMorale: 30).isMoraleCritical, isTrue);
      expect(base.copyWith(budget: 5000).isBudgetCritical, isTrue);
    });

    test('unicornProgress 0-1 aralığında kalır', () {
      final base = GameState.newGame();
      expect(base.copyWith(valuation: 0).unicornProgress, 0.0);
      expect(base.copyWith(valuation: 500000).unicornProgress, 0.5);
      expect(base.copyWith(valuation: 5000000).unicornProgress, 1.0);
    });

    test('copyWith verilmeyen alanları korur', () {
      final base = GameState.newGame();
      final next = base.copyWith(week: 7, techDebt: 42);
      expect(next.week, 7);
      expect(next.techDebt, 42);
      expect(next.budget, base.budget);
      expect(next.valuation, base.valuation);
      expect(next.status, base.status);
    });

    test('clearLossReason kaybetme nedenini temizler', () {
      final lost = GameState.newGame().copyWith(
        status: GameStatus.lost,
        lossReason: LossReason.bankruptcy,
      );
      expect(lost.lossReason, LossReason.bankruptcy);

      final restarted = lost.copyWith(
        status: GameStatus.playing,
        clearLossReason: true,
      );
      expect(restarted.lossReason, isNull);
    });

    test('JSON gidiş-dönüşü ekip dahil değeri korur', () {
      final state = GameState.newGame().copyWith(
        week: 12,
        budget: 23400,
        valuation: 310000,
        weeklyRevenue: 5600,
        techDebt: 48,
        teamMorale: 61,
        resolvedCrises: 4,
        usedFreeHints: 2,
        hiredConsultants: 1,
        team: const [
          Employee(
            id: 'hire_senior#1',
            name: 'Senior Developer',
            title: 'Senior Developer',
            level: EmployeeLevel.senior,
            weeklySalary: 2600,
            revenueContribution: 2000,
            techDebtEffect: -2,
            moraleEffect: 2,
            iconId: 'senior',
          ),
        ],
      );

      final restored = GameState.fromJson(state.toJson());
      expect(restored, state);
      expect(restored.team.single.id, 'hire_senior#1');
    });

    test('kaybedilmiş oyunun JSON gidiş-dönüşü nedeni korur', () {
      final lost = GameState.newGame().copyWith(
        status: GameStatus.lost,
        lossReason: LossReason.serverMeltdown,
      );
      final restored = GameState.fromJson(lost.toJson());
      expect(restored.status, GameStatus.lost);
      expect(restored.lossReason, LossReason.serverMeltdown);
    });

    test('bozuk/eksik kayıt güvenli varsayılanlara düşer', () {
      final restored = GameState.fromJson(<String, dynamic>{});
      expect(restored.week, 1);
      expect(restored.budget, GameState.initialBudget);
      expect(restored.status, GameStatus.playing);
      expect(restored.team, isEmpty);
    });

    test('kayıt şema sürümü JSON içine yazılır', () {
      expect(
        GameState.newGame().toJson()['schemaVersion'],
        GameState.schemaVersion,
      );
    });
  });

  group('GameRecord', () {
    test('fromGameState bitmiş oyundan kayıt üretir', () {
      final state = GameState.newGame().copyWith(
        week: 31,
        valuation: 1000000,
        resolvedCrises: 9,
        status: GameStatus.won,
      );
      final playedAt = DateTime.utc(2026, 3, 14, 9, 26);

      final record = GameRecord.fromGameState(
        state,
        ctoNote: 'Unicorn oldu, teknik borç kaldı.',
        playedAt: playedAt,
      );

      expect(record.weeksSurvived, 31);
      expect(record.finalValuation, 1000000);
      expect(record.resolvedCrises, 9);
      expect(record.outcome, GameStatus.won);
      expect(record.isWin, isTrue);
      expect(record.playedAt, playedAt);
      expect(record.id, isNotEmpty);
    });

    test('JSON gidiş-dönüşü değeri korur', () {
      final record = GameRecord(
        id: '42',
        playedAt: DateTime.utc(2026, 1, 2, 3, 4, 5),
        weeksSurvived: 18,
        finalValuation: 420000,
        resolvedCrises: 5,
        outcome: GameStatus.lost,
        lossReason: LossReason.massResignation,
        ctoNote: 'Ekip gitti, kod kaldı.',
      );
      expect(GameRecord.fromJson(record.toJson()), record);
    });

    test('copyWith verilmeyen alanları korur', () {
      final record = GameRecord(
        id: '1',
        playedAt: DateTime.utc(2026),
        weeksSurvived: 5,
        finalValuation: 60000,
        resolvedCrises: 1,
        outcome: GameStatus.lost,
        lossReason: LossReason.bankruptcy,
        ctoNote: 'not',
      );
      final updated = record.copyWith(weeksSurvived: 6);
      expect(updated.weeksSurvived, 6);
      expect(updated.finalValuation, 60000);
      expect(updated.lossReason, LossReason.bankruptcy);
    });
  });

  group('HintResult', () {
    test('aciliyet 3 ve üstü kritik sayılır', () {
      const hint = HintResult(
        advice: 'Refactoring sprinti yap.',
        reasoning: 'Teknik borç %70.',
        metric: HintMetric.techDebt,
        priority: 3,
      );
      expect(hint.isUrgent, isTrue);
      expect(hint.copyWith(priority: 1).isUrgent, isFalse);
    });

    test('clearSuggestedActionId öneriyi temizler', () {
      const hint = HintResult(
        advice: 'a',
        reasoning: 'b',
        metric: HintMetric.budget,
        suggestedActionId: 'action_refactor',
      );
      expect(
        hint.copyWith(clearSuggestedActionId: true).suggestedActionId,
        isNull,
      );
    });
  });

  group('Character', () {
    test('dialogueAt indeksi replik sayısına göre mod\'lar', () {
      const character = Character(
        id: 'test',
        name: 'Test',
        title: 'Test',
        personality: 'Test',
        iconId: 'test',
        dialogues: {
          DialogueSituation.gameStart: ['bir', 'iki'],
        },
      );

      expect(character.dialogueAt(DialogueSituation.gameStart, 0), 'bir');
      expect(character.dialogueAt(DialogueSituation.gameStart, 1), 'iki');
      expect(character.dialogueAt(DialogueSituation.gameStart, 2), 'bir');
      expect(character.dialogueAt(DialogueSituation.gameStart, -1), 'iki');
      expect(character.dialogueAt(DialogueSituation.crisis, 0), isNull);
      expect(character.dialoguesFor(DialogueSituation.crisis), isEmpty);
    });
  });

  group('model_utils', () {
    test('listEquals eleman eleman karşılaştırır', () {
      expect(listEquals<int>(null, null), isTrue);
      expect(listEquals([1, 2], [1, 2]), isTrue);
      expect(listEquals([1, 2], [2, 1]), isFalse);
      expect(listEquals([1], null), isFalse);
    });

    test('clampInt sınırları uygular', () {
      expect(clampInt(-5, 0, 100), 0);
      expect(clampInt(150, 0, 100), 100);
      expect(clampInt(42, 0, 100), 42);
    });

    test('readInt farklı tipleri tolere eder', () {
      expect(readInt(7), 7);
      expect(readInt(7.6), 8);
      expect(readInt('9'), 9);
      expect(readInt(null, fallback: 3), 3);
      expect(readInt('abc', fallback: 3), 3);
    });

    test('enumFromName ada göre bulur, yoksa varsayılana düşer', () {
      expect(
        enumFromName(GameStatus.values, 'won', fallback: GameStatus.playing),
        GameStatus.won,
      );
      expect(
        enumFromName(GameStatus.values, 'nope', fallback: GameStatus.playing),
        GameStatus.playing,
      );
    });
  });
}
