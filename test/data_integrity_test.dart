import 'package:test/test.dart';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/l10n/l10n.dart';
import 'package:tech_debt_tycoon/models/models.dart';

/// Statik veri bütünlüğü testleri.
///
/// Amaç: bir metin eksik kalırsa ya da bir denge değeri yanlışlıkla
/// değişirse bunu oyun içinde değil burada öğrenmek.
void main() {
  group('Karakterler', () {
    test('dört ana karakter tanımlı ve kimlikleri tekil', () {
      expect(kCharacters, hasLength(4));
      final ids = kCharacters.map((c) => c.id).toSet();
      expect(ids, hasLength(4));
      expect(ids, containsAll(['mert', 'zeynep', 'can', 'elif']));
    });

    test('her karakterin temel alanları dolu', () {
      for (final character in kCharacters) {
        expect(character.id, isNotEmpty, reason: 'kimlik boş');
        expect(character.name, isNotEmpty, reason: '${character.id}: ad boş');
        expect(
          character.title,
          isNotEmpty,
          reason: '${character.id}: unvan boş',
        );
        expect(
          character.personality,
          isNotEmpty,
          reason: '${character.id}: kişilik boş',
        );
        expect(
          character.iconId,
          isNotEmpty,
          reason: '${character.id}: ikon boş',
        );
      }
    });

    test('her karakterin her durum için en az bir repliği var', () {
      for (final character in kCharacters) {
        for (final situation in DialogueSituation.values) {
          final lines = character.dialoguesFor(situation);
          expect(
            lines,
            isNotEmpty,
            reason: '${character.id} için ${situation.name} repliği yok',
          );
          for (final line in lines) {
            expect(
              line.trim(),
              isNotEmpty,
              reason: '${character.id}/${situation.name}: boş replik',
            );
          }
        }
      }
    });

    test('characterById çalışır', () {
      expect(characterById('zeynep')?.name, 'Zeynep');
      expect(characterById('bilinmeyen'), isNull);
    });
  });

  group('Aksiyonlar', () {
    test('beş haftalık aksiyon tanımlı ve kimlikleri tekil', () {
      expect(kGameActions, hasLength(5));
      expect(kGameActions.map((a) => a.id).toSet(), hasLength(5));
    });

    test('her aksiyon türü tam olarak bir kez kullanılmış', () {
      final kinds = kGameActions.map((a) => a.kind).toList();
      expect(kinds.toSet(), hasLength(GameActionKind.values.length));
    });

    test('her aksiyonun metinleri dolu', () {
      for (final action in kGameActions) {
        expect(action.name, isNotEmpty, reason: '${action.id}: ad boş');
        expect(
          action.description,
          isNotEmpty,
          reason: '${action.id}: açıklama boş',
        );
        expect(action.iconId, isNotEmpty, reason: '${action.id}: ikon boş');
      }
    });

    test('Hızlı Feature: +%15 borç, -%6 moral, gelir ve değerleme artar', () {
      expect(kShipFeatureAction.techDebtDelta, 15);
      expect(kShipFeatureAction.moraleDelta, -6);
      expect(kShipFeatureAction.revenueDelta, greaterThan(0));
      expect(kShipFeatureAction.valuationDelta, greaterThan(0));
    });

    test('Temiz Kod: borç üretmez, +%2 moral, dengeli gelir', () {
      expect(kCleanCodeAction.techDebtDelta, 0);
      expect(kCleanCodeAction.moraleDelta, 2);
      expect(kCleanCodeAction.revenueDelta, greaterThan(0));
      // Dengeli olmalı: hızlı feature'dan daha az gelir getirir.
      expect(
        kCleanCodeAction.revenueDelta,
        lessThan(kShipFeatureAction.revenueDelta),
      );
      expect(
        kCleanCodeAction.valuationDelta,
        lessThan(kShipFeatureAction.valuationDelta),
      );
    });

    test('Refactoring: -%25 borç, +%8 moral', () {
      expect(kRefactorAction.techDebtDelta, -25);
      expect(kRefactorAction.moraleDelta, 8);
    });

    test('Ekip Motivasyonu: bütçe harcar, +%20 moral', () {
      expect(kTeamMoraleAction.moraleDelta, 20);
      expect(kTeamMoraleAction.budgetDelta, lessThan(0));
    });

    test('İşe Alım aksiyonunun kendi efekti boş ve seçim ister', () {
      expect(kHireAction.effect.isEmpty, isTrue);
      expect(kHireAction.requiresHireSelection, isTrue);
    });

    test('yalnızca İşe Alım aksiyonu seçim ister', () {
      final needingSelection = kGameActions
          .where((a) => a.requiresHireSelection)
          .toList();
      expect(needingSelection, [kHireAction]);
    });

    test('borç ve moral etkileri makul aralıkta', () {
      for (final action in kGameActions) {
        expect(
          action.techDebtDelta,
          inInclusiveRange(-100, 100),
          reason: '${action.id}: borç etkisi aralık dışı',
        );
        expect(
          action.moraleDelta,
          inInclusiveRange(-100, 100),
          reason: '${action.id}: moral etkisi aralık dışı',
        );
      }
    });

    test('actionById çalışır', () {
      expect(actionById('action_refactor'), kRefactorAction);
      expect(actionById('yok'), isNull);
    });
  });

  group('İşe alım seçenekleri', () {
    test('dört seviye için birer seçenek var', () {
      expect(kHireOptions, hasLength(4));
      expect(
        kHireOptions.map((e) => e.level).toSet(),
        hasLength(EmployeeLevel.values.length),
      );
    });

    test('her seçeneğin maaşı ve gelir katkısı pozitif', () {
      for (final option in kHireOptions) {
        expect(
          option.weeklySalary,
          greaterThan(0),
          reason: '${option.id}: maaş pozitif değil',
        );
        expect(
          option.revenueContribution,
          greaterThan(0),
          reason: '${option.id}: gelir katkısı pozitif değil',
        );
        expect(option.name, isNotEmpty);
        expect(option.title, isNotEmpty);
        expect(option.iconId, isNotEmpty);
      }
    });

    test('junior borç üretir, senior ve devops borcu eritir', () {
      expect(kJuniorHire.techDebtEffect, greaterThan(0));
      expect(kMidHire.techDebtEffect, 0);
      expect(kSeniorHire.techDebtEffect, lessThan(0));
      expect(kDevOpsHire.techDebtEffect, lessThan(0));
    });

    test('devops borcu senior\'dan daha hızlı eritir', () {
      expect(kDevOpsHire.techDebtEffect, lessThan(kSeniorHire.techDebtEffect));
    });

    test('maaşlar seviyeye göre artar (junior < mid < senior)', () {
      expect(kJuniorHire.weeklySalary, lessThan(kMidHire.weeklySalary));
      expect(kMidHire.weeklySalary, lessThan(kSeniorHire.weeklySalary));
    });

    test('işe alım maliyeti pozitif ve maaşla ilişkili', () {
      for (final option in kHireOptions) {
        expect(hiringCost(option), greaterThan(0));
        expect(hiringCost(option), greaterThan(option.weeklySalary));
      }
    });

    test('hiçbir seçenek tek başına başlangıç bütçesini tüketmiyor', () {
      for (final option in kHireOptions) {
        expect(
          hiringCost(option),
          lessThan(GameState.initialBudget),
          reason: '${option.id} ilk haftada alınamaz hâle gelmiş',
        );
      }
    });

    test('hireOptionById çalışır', () {
      expect(hireOptionById('hire_devops'), kDevOpsHire);
      expect(hireOptionById('yok'), isNull);
    });
  });

  group('Sözlük', () {
    test('en az 15 terim var ve kimlikleri tekil', () {
      expect(kGlossaryTerms.length, greaterThanOrEqualTo(15));
      expect(
        kGlossaryTerms.map((t) => t.id).toSet(),
        hasLength(kGlossaryTerms.length),
      );
    });

    test('her terimin dört metin alanı da dolu', () {
      for (final term in kGlossaryTerms) {
        expect(term.id, isNotEmpty);
        expect(term.name.trim(), isNotEmpty, reason: '${term.id}: ad boş');
        expect(
          term.shortDefinition.trim(),
          isNotEmpty,
          reason: '${term.id}: tanım boş',
        );
        expect(
          term.realLifeExample.trim(),
          isNotEmpty,
          reason: '${term.id}: gerçek hayat örneği boş',
        );
        expect(
          term.gameEffect.trim(),
          isNotEmpty,
          reason: '${term.id}: oyun etkisi boş',
        );
      }
    });

    test('metinler yer tutucu/kısa kalmamış', () {
      for (final term in kGlossaryTerms) {
        expect(
          term.shortDefinition.length,
          greaterThan(30),
          reason: '${term.id}: tanım çok kısa',
        );
        expect(
          term.realLifeExample.length,
          greaterThan(30),
          reason: '${term.id}: örnek çok kısa',
        );
        expect(
          term.gameEffect.length,
          greaterThan(30),
          reason: '${term.id}: oyun etkisi çok kısa',
        );
        expect(term.gameEffect, isNot(contains('TODO')));
      }
    });

    test('istenen 15 temel terimin hepsi sözlükte', () {
      const required = [
        'technical_debt',
        'refactoring',
        'sprint',
        'production',
        'deploy',
        'ci_cd',
        'pull_request',
        'unit_test',
        'hotfix',
        'spaghetti_code',
        'bottleneck',
        'rollback',
        'mvp',
        'legacy_code',
        'code_review',
      ];
      for (final id in required) {
        expect(glossaryTermById(id), isNotNull, reason: '$id sözlükte yok');
      }
    });

    test('her kategoride en az bir terim var', () {
      for (final category in GlossaryCategory.values) {
        expect(
          glossaryTermsByCategory(category),
          isNotEmpty,
          reason: '${category.name} kategorisi boş',
        );
      }
    });
  });

  group('Olay kartları', () {
    test('en az 12 kart var ve kimlikleri tekil', () {
      expect(kEventCards.length, greaterThanOrEqualTo(12));
      expect(
        kEventCards.map((c) => c.id).toSet(),
        hasLength(kEventCards.length),
      );
    });

    test('her kartın en az iki seçeneği var', () {
      for (final card in kEventCards) {
        expect(
          card.choices.length,
          greaterThanOrEqualTo(2),
          reason: '${card.id}: ${card.choices.length} seçenek',
        );
        expect(
          card.choices.length,
          lessThanOrEqualTo(3),
          reason: '${card.id}: 3\'ten fazla seçenek',
        );
      }
    });

    test('her kartın metinleri dolu ve konuşanı tanımlı bir karakter', () {
      for (final card in kEventCards) {
        expect(card.title.trim(), isNotEmpty, reason: '${card.id}: başlık boş');
        expect(
          card.narration.trim(),
          isNotEmpty,
          reason: '${card.id}: anlatım boş',
        );
        expect(
          characterById(card.speakerId),
          isNotNull,
          reason: '${card.id}: tanınmayan konuşmacı "${card.speakerId}"',
        );
        expect(card.minWeek, greaterThanOrEqualTo(1));
      }
    });

    test('seçenek kimlikleri kart içinde tekil', () {
      for (final card in kEventCards) {
        final ids = card.choices.map((c) => c.id).toSet();
        expect(
          ids,
          hasLength(card.choices.length),
          reason: '${card.id}: tekrarlanan seçenek kimliği',
        );
      }
    });

    test('her seçeneğin etiketi, sonucu ve sayısal etkisi var', () {
      for (final card in kEventCards) {
        for (final choice in card.choices) {
          final tag = '${card.id}/${choice.id}';
          expect(choice.label.trim(), isNotEmpty, reason: '$tag: etiket boş');
          expect(
            choice.outcomeText.trim(),
            isNotEmpty,
            reason: '$tag: sonuç metni boş',
          );
          expect(
            choice.effect.isEmpty,
            isFalse,
            reason: '$tag: hiçbir etkisi yok (bedava seçenek olmamalı)',
          );
        }
      }
    });

    test('seçenek sonucunu söyleyen karakter tanımlı', () {
      for (final card in kEventCards) {
        for (final choice in card.choices) {
          final speakerId = choice.outcomeSpeakerId;
          if (speakerId == null) continue;
          expect(
            characterById(speakerId),
            isNotNull,
            reason:
                '${card.id}/${choice.id}: tanınmayan konuşmacı "$speakerId"',
          );
        }
      }
    });

    test('seçenek etkileri makul aralıkta', () {
      for (final card in kEventCards) {
        for (final choice in card.choices) {
          final tag = '${card.id}/${choice.id}';
          final effect = choice.effect;
          expect(
            effect.techDebtDelta,
            inInclusiveRange(-40, 40),
            reason: '$tag: borç etkisi aşırı',
          );
          expect(
            effect.moraleDelta,
            inInclusiveRange(-30, 30),
            reason: '$tag: moral etkisi aşırı',
          );
          expect(
            effect.budgetDelta,
            inInclusiveRange(-10000, 10000),
            reason: '$tag: bütçe etkisi aşırı',
          );
          expect(
            effect.revenueDelta,
            inInclusiveRange(-5000, 5000),
            reason: '$tag: gelir etkisi aşırı',
          );
          expect(
            effect.valuationDelta,
            inInclusiveRange(-100000, 100000),
            reason: '$tag: değerleme etkisi aşırı',
          );
        }
      }
    });

    test('her kartta krizi çözen en az bir seçenek yok sayılmamış', () {
      // Kriz kartlarında oyuncunun doğru karar verebileceği bir yol olmalı.
      final crisisCards = kEventCards.where((c) => c.isCrisis);
      expect(crisisCards, isNotEmpty);
      for (final card in crisisCards) {
        expect(
          card.choices.any((c) => c.resolvesCrisis),
          isTrue,
          reason: '${card.id}: krizi çözen hiçbir seçenek yok',
        );
      }
    });

    test('istenen 12 temel olayın hepsi tanımlı', () {
      const required = [
        'event_friday_deploy',
        'event_prod_db_deleted',
        'event_viral_traffic',
        'event_legacy_crisis',
        'event_investor_pitch',
        'event_force_push',
        'event_cloud_bill',
        'event_competitor_launch',
        'event_key_employee_leaving',
        'event_security_report',
        'event_debt_interest',
        'event_successful_launch',
      ];
      for (final id in required) {
        expect(eventCardById(id), isNotNull, reason: '$id tanımlı değil');
      }
    });

    test('ilk haftada en az bir olay çıkabilir', () {
      expect(eventCardsAvailableAt(1), isNotEmpty);
      expect(eventCardsAvailableAt(99).length, kEventCards.length);
    });

    test('choiceById çalışır', () {
      final card = eventCardById('event_friday_deploy')!;
      expect(card.choiceById('deploy_now'), isNotNull);
      expect(card.choiceById('yok'), isNull);
    });
  });

  group('GameContent', () {
    test('Türkçe içerik bütün veri setlerini taşır', () {
      const content = GameContent.turkish;
      expect(content.language.code, 'tr');
      expect(content.characters, hasLength(4));
      expect(content.actions, hasLength(5));
      expect(content.hireOptions, hasLength(4));
      expect(content.events.length, greaterThanOrEqualTo(12));
      expect(content.glossary.length, greaterThanOrEqualTo(15));
    });

    test('of() desteklenmeyen dilde varsayılana düşer', () {
      expect(GameContent.of(AppLanguage.en), GameContent.turkish);
      expect(GameContent.supportedLanguages, contains(AppLanguage.tr));
    });
  });
}
