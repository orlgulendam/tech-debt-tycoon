import 'string_keys.dart';

/// Kayıtlarda saklanan CTO notu anahtarlarını metin anahtarlarına eşler.
///
/// [GameRecord.ctoNote] alanında düz metin değil kısa bir anahtar
/// (`'won_clean'` gibi) saklanıyor; böylece geçmiş kayıtlar dil değişince de
/// doğru dilde gösterilebiliyor. Eşleme tek yerde dursun diye burada.
///
/// Tanınmayan bir anahtar gelirse (eski kayıt, elle kurcalanmış dosya)
/// `null` döner; UI o zaman notu boş bırakır, çökmez.
StringKey? ctoNoteStringKey(String noteKey) => switch (noteKey) {
  'won_clean' => StringKey.ctoNoteWonClean,
  'won_with_debt' => StringKey.ctoNoteWonWithDebt,
  'lost_bankruptcy' => StringKey.ctoNoteLostBankruptcy,
  'lost_meltdown' => StringKey.ctoNoteLostMeltdown,
  'lost_resignation' => StringKey.ctoNoteLostResignation,
  _ => null,
};
