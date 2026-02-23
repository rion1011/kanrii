import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/occasion.dart';

const _kOccasionsKey = 'occasions_v1';

class OccasionRepository {
  final SharedPreferences _prefs;

  // メモリキャッシュ：毎回JSONをパースしない
  List<Occasion>? _cache;

  OccasionRepository(this._prefs);

  List<Occasion> getAll() {
    if (_cache != null) return List.unmodifiable(_cache!);
    final raw = _prefs.getString(_kOccasionsKey);
    if (raw == null) {
      _cache = [];
      return [];
    }
    _cache = (jsonDecode(raw) as List)
        .map((e) => Occasion.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return List.unmodifiable(_cache!);
  }

  Future<void> save(Occasion occasion) async {
    final list = [...getAll()];
    final idx = list.indexWhere((o) => o.id == occasion.id);
    if (idx >= 0) {
      list[idx] = occasion;
    } else {
      list.add(occasion);
    }
    _cache = list;
    await _prefs.setString(
      _kOccasionsKey,
      jsonEncode(list.map((o) => o.toJson()).toList()),
    );
  }

  Future<void> delete(String id) async {
    final list = [...getAll()]..removeWhere((o) => o.id == id);
    _cache = list;
    await _prefs.setString(
      _kOccasionsKey,
      jsonEncode(list.map((o) => o.toJson()).toList()),
    );
  }
}

final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be overridden at root');
});

final occasionRepositoryProvider = Provider<OccasionRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return OccasionRepository(prefs);
});
