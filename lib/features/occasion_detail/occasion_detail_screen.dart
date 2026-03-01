import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/item_provider.dart';
import '../../services/firestore_service.dart';
import 'widgets/item_list_tile.dart';
import 'widgets/add_item_field.dart';

class OccasionDetailScreen extends ConsumerStatefulWidget {
  const OccasionDetailScreen({super.key, required this.occasionId});

  final String occasionId;

  @override
  ConsumerState<OccasionDetailScreen> createState() =>
      _OccasionDetailScreenState();
}

class _OccasionDetailScreenState extends ConsumerState<OccasionDetailScreen> {
  bool _sharing = false;

  Future<void> _share() async {
    final occasion = ref.read(occasionProvider.select((list) {
      try {
        return list.firstWhere((o) => o.id == widget.occasionId);
      } catch (_) {
        return null;
      }
    }));
    final items =
        ref.read(itemsForOccasionProvider(widget.occasionId));

    if (occasion == null) return;

    setState(() => _sharing = true);

    try {
      final shareCode = const Uuid().v4().replaceAll('-', '').substring(0, 8);
      final service = ref.read(firestoreServiceProvider);
      await service.createSession(shareCode, occasion, items);

      final url =
          'https://web-five-pi-45.vercel.app/s/$shareCode/${occasion.id}';

      if (!mounted) return;

      await Share.share(
        '「${occasion.emoji ?? ''}${occasion.name}」の持ち物リストを共有します\n$url',
        subject: '持ち物リスト共有',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('共有リンクの作成に失敗しました')),
      );
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final occasion = ref.watch(occasionProvider.select((list) {
      try {
        return list.firstWhere((o) => o.id == widget.occasionId);
      } catch (_) {
        return null;
      }
    }));
    final items = ref.watch(itemsForOccasionProvider(widget.occasionId));

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
            onPressed: () =>
                context.push('/occasions/${widget.occasionId}/edit'),
          ),
          if (_sharing)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Center(
                  child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))),
            )
          else
            IconButton(
              icon: const Icon(Icons.share_outlined),
              tooltip: '共有',
              onPressed: _share,
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
                : () =>
                    context.push('/occasions/${widget.occasionId}/checklist'),
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
                            .read(itemsForOccasionProvider(widget.occasionId)
                                .notifier)
                            .delete(item.id),
                      );
                    },
                  ),
          ),
          AddItemField(
            onAdd: (name) => ref
                .read(
                    itemsForOccasionProvider(widget.occasionId).notifier)
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
