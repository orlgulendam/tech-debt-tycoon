import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import 'capture_boundary.dart';
import 'character_bubble.dart';
import 'pulse.dart';
import 'score_card.dart';

/// Oyun sonu kartı: skor özeti ve kapanış repliği.
///
/// Bottom sheet değil, ofis ekranının içinde duran bir kart. Nedeni:
/// oyun bittiğinde geriye dönülecek bir "oyun" kalmıyor, dolayısıyla
/// kapatılabilir bir katman göstermek yanıltıcı olurdu. Oyuncunun tek
/// yolu yeni oyun başlatmak.
///
/// Zengin skor kartı (paylaşılabilir görsel) Aşama 4'te gelecek.
class GameOverCard extends ConsumerStatefulWidget {
  const GameOverCard({required this.state, super.key});

  /// Bitmiş oyunun durumu.
  final GameState state;

  @override
  ConsumerState<GameOverCard> createState() => _GameOverCardState();
}

class _GameOverCardState extends ConsumerState<GameOverCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppMotion.celebrate,
  )..forward();

  /// Karneyi görsele çevirmek için.
  final CaptureController _capture = CaptureController();

  /// Paylaşım sürüyor mu? (Butonu kilitlemek ve çift tetiklemeyi önlemek.)
  bool _sharing = false;

  GameState get state => widget.state;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// Karneyi PNG'ye çevirip sistem paylaşım sayfasını açar.
  ///
  /// Görsel üretilemezse yalnızca metin paylaşılıyor: oyuncunun eli boş
  /// kalmasın.
  Future<void> _share() async {
    setState(() => _sharing = true);
    final strings = ref.read(stringsProvider);
    final haptics = ref.read(hapticsProvider);

    final image = await _capture.capturePng();
    final text = strings.format(StringKey.gameOverShareText, {
      'weeks': '${state.week}',
      'valuation': formatMoney(state.valuation),
      'crises': '${state.resolvedCrises}',
    });

    final shared = await ref
        .read(shareServiceProvider)
        .shareScore(
          text: text,
          subject: strings[StringKey.gameOverShareSubject],
          fileName: 'tech-debt-tycoon-skor.png',
          imageBytes: image,
        );

    if (!mounted) return;
    setState(() => _sharing = false);

    if (shared) {
      unawaited(haptics.success());
      return;
    }

    unawaited(haptics.warning());
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(strings[StringKey.gameOverShareFailed])),
    );
  }

  @override
  Widget build(BuildContext context) {
    final won = state.status == GameStatus.won;
    final accent = won ? AppColors.good : AppColors.danger;

    // Kazanınca kart hafifçe büyüyerek ve parlayarak geliyor; kaybedince
    // sadece beliriyor. Kutlama ile başsağlığı aynı animasyonla
    // sunulmamalı.
    final entrance = CurvedAnimation(
      parent: _controller,
      curve: won ? AppMotion.emphasis : AppMotion.enter,
    );

    return ScaleTransition(
      scale: Tween<double>(begin: won ? 0.88 : 0.98, end: 1).animate(entrance),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        child: _buildCard(context, won, accent),
      ),
    );
  }

  Widget _buildCard(BuildContext context, bool won, Color accent) {
    final strings = ref.watch(stringsProvider);
    final characters = ref.watch(contentProvider).characters;
    final textTheme = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        side: BorderSide(color: accent.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppDimens.cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık, sonuç ve sayılar karnenin kendi içinde. Dışarıda
            // tekrar etmiyoruz: aynı cümleyi iki kez göstermek kartı
            // kalabalıklaştırıyordu.
            //
            // Paylaşılan görselin birebir aynısı ekranda duruyor; oyuncu
            // ne paylaşacağını önceden görüyor.
            Pulse(
              active: won,
              minOpacity: 0.7,
              child: CaptureBoundary(
                controller: _capture,
                child: ScoreCard(state: state),
              ),
            ),
            const SizedBox(height: AppDimens.gapLg),
            if (won) ...[
              Text(
                strings[StringKey.gameOverWonSubtitle],
                style: textTheme.bodyMedium,
              ),
              const SizedBox(height: AppDimens.gapLg),
            ],
            // Kapanış repliği: kazandıysak Mert, kaybettiysek Zeynep
            // konuşuyor — ikisi de karakterine uygun.
            CharacterBubble(
              character: _closingSpeaker(characters, won),
              line: _closingLine(characters, won, state),
              accentColor: accent,
              dense: true,
            ),
            const SizedBox(height: AppDimens.gapLg),
            FilledButton.icon(
              onPressed: _sharing ? null : _share,
              icon: _sharing
                  ? const SizedBox(
                      width: AppDimens.iconSm,
                      height: AppDimens.iconSm,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.ios_share, size: AppDimens.iconSm),
              label: Text(strings[StringKey.gameOverShareButton]),
            ),
            const SizedBox(height: AppDimens.gapSm),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(hapticsProvider).selection();
                ref.read(gameControllerProvider.notifier).startNewGame();
              },
              icon: const Icon(AppIcons.newGame, size: AppDimens.iconSm),
              label: Text(strings[StringKey.gameOverRestartButton]),
            ),
          ],
        ),
      ),
    );
  }

  Character? _closingSpeaker(List<Character> characters, bool won) {
    final id = won ? 'mert' : 'zeynep';
    for (final character in characters) {
      if (character.id == id) return character;
    }
    return characters.isEmpty ? null : characters.first;
  }

  String _closingLine(List<Character> characters, bool won, GameState state) {
    final speaker = _closingSpeaker(characters, won);
    final situation = won
        ? DialogueSituation.victory
        : DialogueSituation.defeat;
    // Replik seçimi hafta sayısına bağlı: aynı oyunda hep aynı cümle
    // görünür, farklı oyunlarda değişir.
    return speaker?.dialogueAt(situation, state.week) ?? '';
  }
}
