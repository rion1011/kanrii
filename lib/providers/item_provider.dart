import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/id_generator.dart';
import '../models/item.dart';
import '../repositories/item_repository.dart';

class ItemNotifier extends StateNotifier<List<Item>> {
  ItemNotifier(this._repo, this._occasionId) : super([]) {
    _load();
  }

  final ItemRepository _repo;
  final String _occasionId;

  void _load() {
    state = _repo.getForOccasion(_occasionId);
  }

  Future<void> add(String name) async {
    final sortOrder = state.isEmpty ? 0 : state.last.sortOrder + 1;
    final item = Item(
      id: newId(),
      occasionId: _occasionId,
      name: name,
      sortOrder: sortOrder,
      createdAt: DateTime.now(),
    );
    await _repo.save(item);
    // キャッシュから直接追加（再読み込み不要）
    state = [...state, item];
  }

  Future<void> delete(String id) async {
    await _repo.delete(id);
    // キャッシュから直接削除（再読み込み不要）
    state = state.where((i) => i.id != id).toList();
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final list = [...state];
    if (newIndex > oldIndex) newIndex--;
    final item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    for (var i = 0; i < list.length; i++) {
      list[i].sortOrder = i;
    }
    // 先にUIを更新してから一括保存（体感速度アップ）
    state = list;
    await _repo.saveAll(list);
  }
}

final itemsForOccasionProvider = StateNotifierProvider.family<
    ItemNotifier, List<Item>, String>((ref, occasionId) {
  return ItemNotifier(ref.read(itemRepositoryProvider), occasionId);
});
