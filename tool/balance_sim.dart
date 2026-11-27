// Oyun dengesi simülatörü.
//
// Denge sayılarını tahminle değil ölçümle ayarlamak için. Birkaç farklı
// oyuncu stratejisiyle binlerce oyun koşturur ve kazanma oranı, oyun
// uzunluğu ve kaybetme nedenlerinin dağılımını yazar.
//
// Kullanım:
//   dart run tool/balance_sim.dart
//   dart run tool/balance_sim.dart 5000      # oyun sayısı
//
// Bu bir test değil: bir ölçüm aracı. Sayıları değiştirdikten sonra
// `lib/data/game_balance.dart` içindeki etkisini burada görürsün.

// Bu bir komut satırı aracı; çıktısını stdout'a yazması gerekiyor.
// ignore_for_file: avoid_print

import 'dart:math';

import 'package:tech_debt_tycoon/data/game_content.dart';
import 'package:tech_debt_tycoon/l10n/l10n.dart';
import 'package:tech_debt_tycoon/models/models.dart';
import 'package:tech_debt_tycoon/services/game_engine.dart';
import 'package:tech_debt_tycoon/services/hint_service.dart';

/// Bir oyuncu stratejisi: o anki duruma bakıp aksiyon seçer.
typedef Strategy = GameAction Function(GameState state, Random random);

void main(List<String> args) {
  final games = args.isNotEmpty ? int.parse(args.first) : 2000;

  final strategies = <String, Strategy>{
    'Sadece feature': _alwaysShip,
    'Dengeli (3 feature : 1 refactor)': _balanced,
    'İpucunu dinle': _followHint,
    'Rastgele': _random,
  };

  print('Oyun başına $games simülasyon\n');
  print(
    '${'Strateji'.padRight(34)}'
    '${'Kazanma'.padLeft(8)}'
    '${'Medyan'.padLeft(8)}'
    '${'P10'.padLeft(6)}'
    '${'P90'.padLeft(6)}'
    '   Kaybetme nedenleri',
  );
  print('-' * 100);

  for (final entry in strategies.entries) {
    final result = _run(entry.value, games);
    print(
      '${entry.key.padRight(34)}'
      '${'${(result.winRate * 100).toStringAsFixed(1)}%'.padLeft(8)}'
      '${'${result.medianWeeks}'.padLeft(8)}'
      '${'${result.p10Weeks}'.padLeft(6)}'
      '${'${result.p90Weeks}'.padLeft(6)}'
      '   ${result.lossSummary}',
    );
  }

  print('\nKazanma eşiği: ${GameState.winValuation}\$');
  print('Hedef: kazanan oyunlar 25-40 hafta arası, kazanma oranı stratejiye');
  print('göre belirgin biçimde değişsin (kötü strateji kaybetsin).');
}

/// Tek bir stratejiyle [games] oyun koşturur.
_Result _run(Strategy strategy, int games) {
  final weeksOnWin = <int>[];
  final losses = <LossReason, int>{};
  var wins = 0;

  for (var i = 0; i < games; i++) {
    final random = Random(i);
    var state = GameState.newGame();
    var guard = 0;

    while (state.isPlaying && guard++ < 500) {
      // Bekleyen olay varsa rastgele bir seçenekle kapat.
      if (state.hasPendingEvent) {
        final card = eventCardById(state.pendingEventId!)!;
        final choice = card.choices[random.nextInt(card.choices.length)];
        state = GameEngine.resolveEvent(state, card, choice).state;
        continue;
      }

      var action = strategy(state, random);
      final hire = action.requiresHireSelection
          ? _pickHire(state, random)
          : null;

      // Bütçe yetmiyorsa bedava bir aksiyona düş.
      if (!GameEngine.canAfford(state, action, hire: hire)) {
        action = kShipFeatureAction;
      }

      state = GameEngine.playSprint(
        state,
        action,
        hire: action.requiresHireSelection ? _pickHire(state, random) : null,
        random: random,
      ).state;
    }

    if (state.status == GameStatus.won) {
      wins++;
      weeksOnWin.add(state.week);
    } else if (state.lossReason != null) {
      losses.update(state.lossReason!, (v) => v + 1, ifAbsent: () => 1);
    }
  }

  weeksOnWin.sort();
  return _Result(
    winRate: wins / games,
    weeksOnWin: weeksOnWin,
    losses: losses,
    games: games,
  );
}

/// Bütçeye sığan en iyi adayı seçer.
Employee _pickHire(GameState state, Random random) {
  final affordable = kHireOptions
      .where((e) => hiringCost(e) <= state.budget)
      .toList();
  if (affordable.isEmpty) return kJuniorHire;
  // Teknik borç yüksekse borcu eriten birini al.
  if (state.isTechDebtCritical) {
    final fixers = affordable.where((e) => e.techDebtEffect < 0).toList();
    if (fixers.isNotEmpty) return fixers.last;
  }
  return affordable[random.nextInt(affordable.length)];
}

// --- Stratejiler --------------------------------------------------------

GameAction _alwaysShip(GameState state, Random random) => kShipFeatureAction;

GameAction _balanced(GameState state, Random random) {
  if (state.techDebt >= 55) return kRefactorAction;
  if (state.teamMorale <= 35) return kTeamMoraleAction;
  if (state.team.length < 3 && state.budget > 12000) return kHireAction;
  return kShipFeatureAction;
}

/// İpucu algoritmasının önerdiği aksiyonu oynar.
final _hintService = HintService(AppStrings.of(AppLanguage.tr));

GameAction _followHint(GameState state, Random random) {
  final hint = _hintService.forState(state);
  final id = hint.suggestedActionId;
  if (id == null) return kShipFeatureAction;
  return actionById(id) ?? kShipFeatureAction;
}

GameAction _random(GameState state, Random random) =>
    kGameActions[random.nextInt(kGameActions.length)];

// --- Sonuç --------------------------------------------------------------

class _Result {
  _Result({
    required this.winRate,
    required this.weeksOnWin,
    required this.losses,
    required this.games,
  });

  final double winRate;
  final List<int> weeksOnWin;
  final Map<LossReason, int> losses;
  final int games;

  int get medianWeeks => _percentile(0.5);
  int get p10Weeks => _percentile(0.1);
  int get p90Weeks => _percentile(0.9);

  int _percentile(double p) {
    if (weeksOnWin.isEmpty) return 0;
    final index = (weeksOnWin.length * p).floor().clamp(
      0,
      weeksOnWin.length - 1,
    );
    return weeksOnWin[index];
  }

  String get lossSummary {
    if (losses.isEmpty) return '-';
    final parts = losses.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return parts
        .map(
          (e) =>
              '${_lossLabel(e.key)} ${(e.value / games * 100).toStringAsFixed(0)}%',
        )
        .join(', ');
  }

  String _lossLabel(LossReason reason) => switch (reason) {
    LossReason.bankruptcy => 'iflas',
    LossReason.serverMeltdown => 'borç',
    LossReason.massResignation => 'moral',
  };
}
