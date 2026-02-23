import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/occasion.dart';

const _kOccasionsKey = 'occasions_v1';

class OccasionRepository {
  final SharedPreferences _prefs;

  OccasionRepository(this._prefs);

  List<Occasion> getAll() {
    final raw = _prefs.getString(_kOccasionsKey);
    if (raw == null) return [];
    final list = (jsonDecode(raw) as List)
        .map((e) => Occasion.fromJson(e as Map<String, dynamic>))
        .toList();
    list.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return list;
  }

  Future<void> save(Occasion occasion) async {
    final list = getAll();
    final idx = list.indexWhere((o) => o.id == occasion.id);
    if (idx >= 0) {
      list[idx] = occasion;
    } else {
      list.add(occasion);
    }
    await _prefs.setString(
      _kOccasionsKey,
      jsonEncode(list.map((o) => o.toJson()).toList()),
    );
  }

  Future<void> delete(String id) async {
    final list = getAll()..removeWhere((o) => o.id == id);
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
