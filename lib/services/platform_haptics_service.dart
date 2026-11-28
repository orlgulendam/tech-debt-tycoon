import 'package:flutter/services.dart';

import 'haptics_service.dart';

/// Platformun titreşim motorunu kullanan gerçek uygulama.
///
/// Flutter'a bağımlı olduğu için [HapticsService] arayüzünden ayrı
/// dosyada: `lib/providers/` ve `lib/services/` çekirdeği saf Dart
/// kalmalı. Bu uygulama yalnızca `main()` içinde provider'a enjekte
/// ediliyor.
class PlatformHapticsService implements HapticsService {
  const PlatformHapticsService();

  @override
  Future<void> selection() => HapticFeedback.selectionClick();

  @override
  Future<void> impact() => HapticFeedback.mediumImpact();

  // Flutter'da "başarı"ya karşılık gelen ayrı bir kalıp yok; hafif ve
  // kısa bir vuruş en yakını.
  @override
  Future<void> success() => HapticFeedback.lightImpact();

  @override
  Future<void> warning() => HapticFeedback.heavyImpact();
}
