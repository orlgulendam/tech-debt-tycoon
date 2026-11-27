import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n/l10n.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../theme/theme.dart';
import '../widgets/widgets.dart';

/// Sözlük sekmesi: yazılım terimleri, arama ve kategori filtresi.
///
/// Oyunun eğitici tarafı burada yaşıyor. Terimler oyun mekaniğine bağlı
/// anlatıldığı için (her kartta "oyundaki etkisi" var) oyuncu öğrendiği
/// şeyi hemen uygulayabiliyor.
class GlossaryScreen extends ConsumerStatefulWidget {
  const GlossaryScreen({super.key});

  @override
  ConsumerState<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends ConsumerState<GlossaryScreen> {
  final _searchController = TextEditingController();

  /// Seçili kategori; `null` ise tümü.
  GlossaryCategory? _category;

  /// Küçük/büyük harf ve Türkçe karakter duyarsız arama metni.
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = ref.watch(stringsProvider);
    final terms = _filtered(ref.watch(contentProvider).glossary);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimens.screenPadding,
            AppDimens.screenPadding,
            AppDimens.screenPadding,
            AppDimens.gapSm,
          ),
          child: TextField(
            controller: _searchController,
            onChanged: (value) => setState(() => _query = value),
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: strings[StringKey.glossarySearchHint],
              prefixIcon: const Icon(Icons.search, size: AppDimens.iconMd),
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close, size: AppDimens.iconSm),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                    ),
            ),
          ),
        ),

        // Kategori filtresi: yatay kaydırmalı çipler.
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimens.screenPadding,
            ),
            children: [
              _CategoryChip(
                label: strings[StringKey.glossaryCategoryAll],
                selected: _category == null,
                onSelected: () => setState(() => _category = null),
              ),
              for (final category in GlossaryCategory.values)
                _CategoryChip(
                  label: strings[category.labelKey],
                  icon: AppIcons.forGlossaryCategory(category),
                  selected: _category == category,
                  onSelected: () => setState(() => _category = category),
                ),
            ],
          ),
        ),

        Expanded(
          child: terms.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppDimens.gapXl),
                    child: Text(
                      strings[StringKey.glossaryNoResults],
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppDimens.screenPadding),
                  itemCount: terms.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppDimens.gapSm),
                  itemBuilder: (context, index) => _TermTile(
                    term: terms[index],
                    onTap: () => showGlossarySheet(context, terms[index]),
                  ),
                ),
        ),
      ],
    );
  }

  /// Arama metni ve kategoriye göre terimleri süzer.
  List<GlossaryTerm> _filtered(List<GlossaryTerm> all) {
    final query = _normalize(_query);

    return all.where((term) {
      if (_category != null && term.category != _category) return false;
      if (query.isEmpty) return true;
      // Hem terim adında hem tanımında ara: oyuncu "borç" yazıp
      // Technical Debt'i bulabilsin.
      return _normalize(term.name).contains(query) ||
          _normalize(term.shortDefinition).contains(query) ||
          _normalize(term.gameEffect).contains(query);
    }).toList();
  }

  /// Aramayı Türkçe karakterlere ve büyük/küçük harfe duyarsız yapar.
  ///
  /// `toLowerCase` Türkçe'de yetmiyor (I/ı, İ/i) ve oyuncu "borc" yazıp
  /// "borç" bulmayı bekliyor.
  String _normalize(String input) {
    const replacements = {
      'ı': 'i',
      'İ': 'i',
      'ş': 's',
      'ğ': 'g',
      'ü': 'u',
      'ö': 'o',
      'ç': 'c',
      'â': 'a',
      'î': 'i',
    };
    var text = input.toLowerCase();
    for (final entry in replacements.entries) {
      text = text.replaceAll(entry.key, entry.value);
      text = text.replaceAll(
        entry.key.toUpperCase().toLowerCase(),
        entry.value,
      );
    }
    return text;
  }
}

/// Kategori filtre çipi.
class _CategoryChip extends StatelessWidget {
  const _CategoryChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: AppDimens.gapSm),
      child: FilterChip(
        label: Text(label),
        avatar: icon == null ? null : Icon(icon, size: 14),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}

/// Sözlük listesindeki tek satır.
class _TermTile extends StatelessWidget {
  const _TermTile({required this.term, required this.onTap});

  final GlossaryTerm term;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimens.radiusCard),
        child: Padding(
          padding: const EdgeInsets.all(AppDimens.cardPadding),
          child: Row(
            children: [
              Icon(
                AppIcons.forGlossaryCategory(term.category),
                size: AppDimens.iconMd,
                color: AppColors.accent,
              ),
              const SizedBox(width: AppDimens.gapMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(term.name, style: textTheme.titleSmall),
                    const SizedBox(height: 2),
                    Text(
                      term.shortDefinition,
                      style: textTheme.bodySmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textMuted,
                size: AppDimens.iconMd,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
