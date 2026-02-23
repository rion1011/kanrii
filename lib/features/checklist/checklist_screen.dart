import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/occasion_provider.dart';
import '../../providers/item_provider.dart';
import '../../providers/checklist_provider.dart';
import 'widgets/checklist_tile.dart';

class ChecklistScreen extends ConsumerStatefulWidget {
  const ChecklistScreen({super.key, required this.occasionId});

  final String occasionId;

  @override
  ConsumerState<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends ConsumerState<ChecklistScreen> {
  bool _completionShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(itemsForOccasionProvider(widget.occasionId));
      final ids = items.map((i) => i.id).toList();
      ref
          .read(checklistProvider(widget.occasionId).notifier)
          .initWithIds(ids);
    });
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
    final checkState = ref.watch(checklistProvider(widget.occasionId));
    final notifier = ref.read(checklistProvider(widget.occasionId).notifier);

    final checkedCount = checkState.values.where((v) => v).length;
    final total = items.length;
    final allChecked = total > 0 && checkedCount == total;

    if (allChecked && !_completionShown) {
      _completionShown = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('持ち物の準備が完了しました！'),
            duration: Duration(seconds: 3),
          ),
        );
      });
    }

    if (!allChecked) {
      _completionShown = false;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          occasion != null
              ? '${occasion.emoji != null ? '${occasion.emoji!} ' : ''}${occasion.name}'
              : 'チェックリスト',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$checkedCount / $total',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
      body: items.isEmpty
          ? const Center(
              child: Text(
                '持ち物がありません',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            )
          : Column(
              children: [
                if (total > 0) _ProgressBar(checked: checkedCount, total: total),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: items.length,
                    itemBuilder: (ctx, i) {
                      final item = items[i];
                      final checked = checkState[item.id] ?? false;
                      return ChecklistTile(
                        item: item,
                        checked: checked,
                        onToggle: () => notifier.toggle(item.id),
                      );
                    },
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          notifier.resetAll();
          setState(() => _completionShown = false);
        },
        tooltip: 'リセット',
        child: const Icon(Icons.refresh_rounded),
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.checked, required this.total});

  final int checked;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = total == 0 ? 0.0 : checked / total;
    return Container(
      height: 3,
      color: AppColors.surfaceVariant,
      child: FractionallySizedBox(
        widthFactor: progress,
        alignment: Alignment.centerLeft,
        child: Container(color: AppColors.checkboxActive),
      ),
    );
  }
}
