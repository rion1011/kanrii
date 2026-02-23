import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../models/occasion.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/item_provider.dart';
import 'widgets/occasion_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final occasions = ref.watch(occasionProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('カンリィ'),
      ),
      body: occasions.isEmpty
          ? _EmptyState()
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: occasions.length,
              itemBuilder: (ctx, i) {
                final occasion = occasions[i];
                return _OccasionCardWrapper(occasion: occasion);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/occasions/new'),
        tooltip: '用事を追加',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _OccasionCardWrapper extends ConsumerWidget {
  const _OccasionCardWrapper({required this.occasion});
  final Occasion occasion;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final items = ref.watch(itemsForOccasionProvider(occasion.id));

    return Dismissible(
      key: Key('occasion_${occasion.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _confirmDelete(context, ref, occasion),
      background: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.deleteRed,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: OccasionCard(
        occasion: occasion,
        itemCount: items.length,
        onTap: () => context.push('/occasions/${occasion.id}/detail'),
        onLongPress: () => _showOptions(context, ref, occasion),
      ),
    );
  }

  void _showOptions(
      BuildContext context, WidgetRef ref, Occasion occasion) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.textDisabled,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.play_circle_outline,
                  color: AppColors.accentLight),
              title: const Text('チェックリスト開始'),
              onTap: () {
                Navigator.pop(context);
                context.push('/occasions/${occasion.id}/checklist');
              },
            ),
            ListTile(
              leading:
                  const Icon(Icons.edit_outlined, color: AppColors.textSecondary),
              title: const Text('編集'),
              onTap: () {
                Navigator.pop(context);
                context.push('/occasions/${occasion.id}/edit');
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: AppColors.deleteRed),
              title: const Text(
                '削除',
                style: TextStyle(color: AppColors.deleteRed),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context, ref, occasion);
                // ignore: unawaited_futures
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(
      BuildContext context, WidgetRef ref, Occasion occasion) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('用事を削除'),
        content: Text(
          '「${occasion.name}」と関連する全ての持ち物を削除します。',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('キャンセル',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('削除',
                style: TextStyle(color: AppColors.deleteRed)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      ref.read(occasionProvider.notifier).delete(occasion.id);
    }
    return confirmed == true;
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 64,
            color: AppColors.textDisabled,
          ),
          const SizedBox(height: 16),
          Text(
            '用事がまだありません',
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            '右下のボタンから追加してください',
            style: Theme.of(context)
                .textTheme
                .bodyMedium,
          ),
        ],
      ),
    );
  }
}
