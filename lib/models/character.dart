/// Bir karakterin konuşabileceği oyun durumları.
///
/// Aşama 2'deki diyalog seçici, o anki [GameState]'e bakıp uygun durumu
/// belirler ve karakterin o duruma ait repliklerinden birini seçer.
enum DialogueSituation {
  /// Oyunun ilk haftası; tanışma ve kurulum replikleri.
  gameStart,

  /// Teknik borç kritik eşiğin üstünde.
  highTechDebt,

  /// Ekip morali düşük.
  lowMorale,

  /// Bütçe tükenmek üzere.
  lowBudget,

  /// İyi geçen bir hafta (değerleme arttı, borç kontrol altında).
  goodWeek,

  /// Bir olay kartı/kriz anı.
  crisis,

  /// Oyun kazanıldı (Unicorn).
  victory,

  /// Oyun kaybedildi.
  defeat,
}

/// Oyunun ana karakterlerinden biri.
///
/// Replikler [dialogues] içinde duruma göre gruplanır. Metinler şu an Türkçe
/// sabitlerdir; ileride ikinci bir dil eklenirken `lib/data/characters.dart`
/// dosyasının dile göre bir eşi üretilir ve provider hangi dil dosyasını
/// okuyacağını seçer (bkz. `lib/l10n/`).
class Character {
  const Character({
    required this.id,
    required this.name,
    required this.title,
    required this.personality,
    required this.iconId,
    required this.dialogues,
  });

  /// Tekil kimlik (ör. `mert`). Olay kartları konuşan karakteri bununla işaret eder.
  final String id;

  /// Karakterin adı (kullanıcıya görünür).
  final String name;

  /// Unvanı (kullanıcıya görünür, ör. "Vizyoner CEO").
  final String title;

  /// Kişilik özeti. Sözlük/ekip ekranında kısa tanıtım olarak gösterilir.
  final String personality;

  /// Avatar/ikon tanımlayıcısı. Aşama 3'te tema katmanı bir ikona eşler.
  final String iconId;

  /// Duruma göre replik setleri.
  ///
  /// Her durum için en az bir replik bulunur; birden fazlaysa motor rastgele seçer.
  final Map<DialogueSituation, List<String>> dialogues;

  /// Verilen durum için replik listesi. Durum tanımlı değilse boş liste döner.
  List<String> dialoguesFor(DialogueSituation situation) =>
      dialogues[situation] ?? const [];

  /// Verilen durum için bir replik seçer.
  ///
  /// [index] replik sayısına göre mod'lanır; böylece çağıran taraf rastgele
  /// sayı üretecini kendi kontrol eder (test edilebilirlik için).
  /// Durum için replik yoksa `null` döner.
  String? dialogueAt(DialogueSituation situation, int index) {
    final lines = dialoguesFor(situation);
    if (lines.isEmpty) return null;
    return lines[index.abs() % lines.length];
  }

  Character copyWith({
    String? id,
    String? name,
    String? title,
    String? personality,
    String? iconId,
    Map<DialogueSituation, List<String>>? dialogues,
  }) => Character(
    id: id ?? this.id,
    name: name ?? this.name,
    title: title ?? this.title,
    personality: personality ?? this.personality,
    iconId: iconId ?? this.iconId,
    dialogues: dialogues ?? this.dialogues,
  );

  @override
  String toString() => 'Character($id, $name)';
}
