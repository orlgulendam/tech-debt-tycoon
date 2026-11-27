import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/game_content.dart';
import '../../l10n/l10n.dart';
import '../../models/models.dart';
import '../../providers/providers.dart';
import '../../services/game_engine.dart';
import '../../theme/theme.dart';
import '../employee_card.dart';
import 'sheet_scaffold.dart';

/// İşe alım sheet'i: adaylar arasından seçim.
///
/// Her adayın maaşı, gelir katkısı ve pasif borç/moral etkisi kartında
/// yazılı; bütçe yetmeyen aday kilitli görünür. Seçim yapıldığında işe
/// alım aksiyonu o adayla oynanır ve sheet kapanır.
class HireSheet extends ConsumerWidget {
  const HireSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(stringsProvider);
    final state = ref.watch(gameControllerProvider);
    final candidates = ref.watch(contentProvider).hireOptions;

    return SheetScaffold(
      title: strings[StringKey.teamHireSectionTitle],
      icon: AppIcons.forId('person_add'),
      accentColor: AppColors.good,
      children: [
        for (final candidate in candidates) ...[
          EmployeeCard(
            employee: candidate,
            hireCost: hiringCost(candidate),
            affordable: GameEngine.canAfford(
              state,
              kHireAction,
              hire: candidate,
            ),
            onHire: () => _hire(context, ref, candidate),
          ),
          const SizedBox(height: AppDimens.gapMd),
        ],
      ],
    );
  }

  void _hire(BuildContext context, WidgetRef ref, Employee candidate) {
    final result = ref
        .read(gameControllerProvider.notifier)
        .playSprint(kHireAction, hire: candidate);

    // Sheet'i kapatırken sonucu döndür: çağıran taraf olay kartı çıktıysa
    // onu açacak.
    Navigator.of(context).pop(result);
  }
}

/// İşe alım sheet'ini açar; sprint oynandıysa sonucunu döner.
Future<SprintResult?> showHireSheet(BuildContext context) {
  return showAppSheet<SprintResult>(
    context: context,
    builder: (context) => const HireSheet(),
  );
}
