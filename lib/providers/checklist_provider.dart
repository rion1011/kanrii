import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChecklistNotifier extends StateNotifier<Map<String, bool>> {
  ChecklistNotifier(List<String> itemIds)
      : super({for (final id in itemIds) id: false});

  void toggle(String itemId) {
    state = {...state, itemId: !(state[itemId] ?? false)};
  }

  void resetAll() {
    state = {for (final key in state.keys) key: false};
  }

  void initWithIds(List<String> itemIds) {
    state = {for (final id in itemIds) id: false};
  }

  int get checkedCount => state.values.where((v) => v).length;

  bool get allChecked =>
      state.isNotEmpty && state.values.every((v) => v);
}

final checklistProvider = StateNotifierProvider.family<
    ChecklistNotifier, Map<String, bool>, String>((ref, occasionId) {
  return ChecklistNotifier([]);
});
