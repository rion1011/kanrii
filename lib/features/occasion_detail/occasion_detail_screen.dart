import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/item_provider.dart';
import 'widgets/item_list_tile.dart';
import 'widgets/add_item_field.dart';

class OccasionDetailScreen extends ConsumerWidget {
  const OccasionDetailScreen({super.key, required this.occasionId});

  final String occasionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occasion =
        ref.watch(occasionProvider.select((list) {
      try {
        return list.firstWhere((o) => o.id == occasionId);
      } catch (_) {
        return null;
      }
    }));
    final items = ref.watch(itemsForOccasionProvider(occasionId));

    if (occasion == null) {
      return Scaffold(
        appBar: AppBar(),
        body: const Center(child: Text('用事が見つかりません')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${occasion.emoji != null ? '${occasion.emoji!} ' : ''}${occasion.name}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '編集',
            onPressed: () => context.push('/occasions/$occasionId/edit'),
          ),
          TextButton.icon(
            icon: const Icon(
              Icons.play_circle_outline,
              color: AppColors.accentLight,
            ),
            label: const Text(
              'チェック',
              style: TextStyle(color: AppColors.accentLight),
            ),
            onPressed: items.isEmpty
                ? null
                : () => context.push('/occasions/$occasionId/checklist'),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: items.isEmpty
                ? _EmptyItemState()
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      return ItemListTile(
                        key: Key(item.id),
                        item: item,
                        onDelete: () => ref
                            .read(itemsForOccasionProvider(occasionId).notifier)
                            .delete(item.id),
                      );
                    },
                  ),
          ),
          AddItemField(
            onAdd: (name) => ref
                .read(itemsForOccasionProvider(occasionId).notifier)
                .add(name),
          ),
        ],
      ),
    );
  }
}

class _EmptyItemState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.add_box_outlined,
            size: 52,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 12),
          Text(
            '持ち物がまだありません',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            '下のフィールドから追加してください',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
