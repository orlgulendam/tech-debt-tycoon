// Bkz. storage_service.dart: gizli alanlar icin bu lint yanlis pozitif.
// ignore_for_file: prefer_initializing_formals

import 'dart:convert';

import 'package:hive_flutter/hive_flutter.dart';

import '../l10n/app_language.dart';
import '../models/models.dart';
import 'storage_service.dart';

/// Hive tabanlı kalıcı kayıt.
///
/// Modeller Hive kutusuna **JSON metni** olarak yazılır, üretilmiş
/// `TypeAdapter` ile değil. Gerekçe `pubspec.yaml` içinde yazılı; kısaca:
/// tek serileştirme yolu, kod üretme adımı yok, modeller saf Dart kalıyor
/// ve `typeId` yönetimi derdi olmuyor.
///
/// JSON metni (map değil) tutmanın pratik faydası: Hive iç içe map'leri
/// `Map<dynamic, dynamic>` olarak geri verir ve her okumada tip dönüşümü
/// gerekir. Metin olarak tutunca `jsonDecode` doğru tipleri kendisi kuruyor.
class HiveStorageService implements StorageService {
  HiveStorageService({Box<dynamic>? box}) : _box = box;

  Box<dynamic>? _box;

  Box<dynamic> get _requireBox {
    final box = _box;
    if (box == null) {
      throw StateError('HiveStorageService.init() çağrılmadı.');
    }
    return box;
  }

  @override
  Future<void> init() async {
    if (_box != null) return;
    await Hive.initFlutter();
    _box = await Hive.openBox<dynamic>(StorageKeys.boxName);
  }

  @override
  GameState? loadGameState() {
    final raw = _requireBox.get(StorageKeys.gameState);
    if (raw is! String || raw.isEmpty) return null;
    final decoded = _decodeMap(raw);
    if (decoded == null) return null;
    return GameState.fromJson(decoded);
  }

  @override
  Future<void> saveGameState(GameState state) =>
      _requireBox.put(StorageKeys.gameState, jsonEncode(state.toJson()));

  @override
  Future<void> clearGameState() => _requireBox.delete(StorageKeys.gameState);

  @override
  List<GameRecord> loadRecords() {
    final raw = _requireBox.get(StorageKeys.records);
    if (raw is! List) return const [];

    final records = <GameRecord>[];
    for (final entry in raw) {
      if (entry is! String) continue;
      final decoded = _decodeMap(entry);
      if (decoded == null) continue;
      records.add(GameRecord.fromJson(decoded));
    }
    records.sort((a, b) => b.playedAt.compareTo(a.playedAt));
    return records;
  }

  @override
  Future<void> addRecord(GameRecord record) async {
    final raw = _requireBox.get(StorageKeys.records);
    final existing = raw is List
        ? raw.whereType<String>().toList()
        : <String>[];
    existing.add(jsonEncode(record.toJson()));
    await _requireBox.put(StorageKeys.records, existing);
  }

  @override
  Future<void> clearRecords() => _requireBox.delete(StorageKeys.records);

  @override
  bool get onboardingCompleted {
    final raw = _requireBox.get(StorageKeys.onboardingCompleted);
    return raw is bool ? raw : false;
  }

  @override
  Future<void> setOnboardingCompleted(bool value) =>
      _requireBox.put(StorageKeys.onboardingCompleted, value);

  @override
  AppLanguage get language {
    final raw = _requireBox.get(StorageKeys.language);
    return AppLanguage.fromCode(raw is String ? raw : null);
  }

  @override
  Future<void> setLanguage(AppLanguage language) =>
      _requireBox.put(StorageKeys.language, language.code);

  @override
  Future<void> close() async {
    await _box?.close();
    _box = null;
  }

  /// Bozuk JSON'u hata fırlatmadan atlar.
  ///
  /// Kayıt dosyası elle kurcalanmış ya da yarım yazılmış olabilir; böyle bir
  /// durumda oyunun açılmaması en kötü sonuç olur. Bozuk kaydı yok sayıp
  /// yeni oyuna başlamak daha iyi.
  Map<String, dynamic>? _decodeMap(String raw) {
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } on FormatException {
      return null;
    }
  }
}
