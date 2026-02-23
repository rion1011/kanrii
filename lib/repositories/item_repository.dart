import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/item.dart';
import 'occasion_repository.dart';

const _kItemsKey = 'items_v1';

class ItemRepository {
  final SharedPreferences _prefs;

  ItemRepository(this._prefs);

  List<Item> _getAll() {
    final raw = _prefs.getString(_kItemsKey);
    if (raw == null) return [];
    return (jsonDecode(raw) as List)
        .map((e) => Item.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _saveAll(List<Item> items) async {
    await _prefs.setString(
      _kItemsKey,
      jsonEncode(items.map((i) => i.toJson()).toList()),
    );
  }

  List<Item> getForOccasion(String occasionId) {
    final list = _getAll().where((i) => i.occasionId == occasionId).toList();
    list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
    return list;
  }

  Future<void> save(Item item) async {
    final list = _getAll();
    final idx = list.indexWhere((i) => i.id == item.id);
    if (idx >= 0) {
      list[idx] = item;
    } else {
      list.add(item);
    }
    await _saveAll(list);
  }

  Future<void> delete(String id) async {
    final list = _getAll()..removeWhere((i) => i.id == id);
    await _saveAll(list);
  }

  Future<void> deleteAllForOccasion(String occasionId) async {
    final list = _getAll()..removeWhere((i) => i.occasionId == occasionId);
    await _saveAll(list);
  }
}

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return ItemRepository(prefs);
});
