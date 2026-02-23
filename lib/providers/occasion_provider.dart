import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/id_generator.dart';
import '../models/occasion.dart';
import '../repositories/occasion_repository.dart';
import '../repositories/item_repository.dart';

class OccasionNotifier extends StateNotifier<List<Occasion>> {
  OccasionNotifier(this._repo, this._itemRepo) : super([]) {
    _load();
  }

  final OccasionRepository _repo;
  final ItemRepository _itemRepo;

  void _load() {
    state = _repo.getAll();
  }

  Future<void> add(String name, String? emoji) async {
    final now = DateTime.now();
    final occasion = Occasion(
      id: newId(),
      name: name,
      emoji: emoji,
      createdAt: now,
      updatedAt: now,
    );
    await _repo.save(occasion);
    state = _repo.getAll();
  }

  Future<void> update(String id, String name, String? emoji) async {
    final occasion = state.firstWhere((o) => o.id == id);
    occasion.name = name;
    occasion.emoji = emoji;
    occasion.updatedAt = DateTime.now();
    await _repo.save(occasion);
    state = _repo.getAll();
  }

  Future<void> delete(String id) async {
    await _itemRepo.deleteAllForOccasion(id);
    await _repo.delete(id);
    state = _repo.getAll();
  }

  Occasion? findById(String id) {
    try {
      return state.firstWhere((o) => o.id == id);
    } catch (_) {
      return null;
    }
  }
}

final occasionProvider =
    StateNotifierProvider<OccasionNotifier, List<Occasion>>((ref) {
  return OccasionNotifier(
    ref.read(occasionRepositoryProvider),
    ref.read(itemRepositoryProvider),
  );
});
