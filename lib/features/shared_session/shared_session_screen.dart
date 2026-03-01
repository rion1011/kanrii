import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../models/item.dart';
import '../../providers/shared_session_provider.dart';
import '../../services/firestore_service.dart';

class SharedSessionScreen extends ConsumerStatefulWidget {
  const SharedSessionScreen({
    super.key,
    required this.shareCode,
    required this.occasionId,
  });

  final String shareCode;
  final String occasionId;

  @override
  ConsumerState<SharedSessionScreen> createState() =>
      _SharedSessionScreenState();
}

class _SharedSessionScreenState extends ConsumerState<SharedSessionScreen> {
  final _controller = TextEditingController();

  Future<void> _addItem(String name) async {
    if (name.trim().isEmpty) return;
    final service = ref.read(firestoreServiceProvider);
    final items = ref.read(sharedItemsProvider(
        (shareCode: widget.shareCode, occasionId: widget.occasionId)));
    final currentItems = items.valueOrNull ?? [];
    final item = Item(
      id: const Uuid().v4(),
      occasionId: widget.occasionId,
      name: name.trim(),
      sortOrder: currentItems.length,
      createdAt: DateTime.now(),
    );
    await service.saveItem(widget.shareCode, widget.occasionId, item);
    _controller.clear();
  }

  Future<void> _deleteItem(String itemId) async {
    final service = ref.read(firestoreServiceProvider);
    await service.deleteItem(widget.shareCode, widget.occasionId, itemId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final params =
        (shareCode: widget.shareCode, occasionId: widget.occasionId);
    final occasionAsync = ref.watch(sharedOccasionProvider(params));
    final itemsAsync = ref.watch(sharedItemsProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: occasionAsync.when(
          data: (occasion) => Text(
            occasion != null
                ? '${occasion.emoji != null ? '${occasion.emoji!} ' : ''}${occasion.name}'
                : '共有リスト',
          ),
          loading: () => const Text('読み込み中...'),
          error: (_, __) => const Text('共有リスト'),
        ),
      ),
      body: itemsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Text(
            'エラーが発生しました',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ),
        data: (items) => Column(
          children: [
            Expanded(
              child: items.isEmpty
                  ? const Center(
                      child: Text(
                        '持ち物がまだありません',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: items.length,
                      itemBuilder: (ctx, i) {
                        final item = items[i];
                        return ListTile(
                          title: Text(item.name),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: AppColors.deleteRed),
                            onPressed: () => _deleteItem(item.id),
                          ),
                        );
                      },
                    ),
            ),
            _AddItemBar(
              controller: _controller,
              onAdd: _addItem,
            ),
          ],
        ),
      ),
    );
  }
}

class _AddItemBar extends StatelessWidget {
  const _AddItemBar({required this.controller, required this.onAdd});

  final TextEditingController controller;
  final void Function(String) onAdd;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.surface,
      padding: EdgeInsets.only(
        left: 16,
        right: 8,
        top: 8,
        bottom: MediaQuery.of(context).viewInsets.bottom + 8,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: '持ち物を追加',
                border: InputBorder.none,
              ),
              onSubmitted: onAdd,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            onPressed: () => onAdd(controller.text),
          ),
        ],
      ),
    );
  }
}
