import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/occasion_provider.dart';

class OccasionFormScreen extends ConsumerStatefulWidget {
  const OccasionFormScreen({super.key, required this.occasionId});

  final String? occasionId;

  @override
  ConsumerState<OccasionFormScreen> createState() =>
      _OccasionFormScreenState();
}

class _OccasionFormScreenState extends ConsumerState<OccasionFormScreen> {
  late final TextEditingController _nameController;
  String? _selectedEmoji;
  bool _isLoading = false;

  static const _emojiOptions = [
    '💼', '✈️', '🏋️', '🛒', '🏥', '🎓', '🎉', '⛺',
    '🚗', '🏖️', '🎮', '📚',
  ];

  @override
  void initState() {
    super.initState();
    final occasion = widget.occasionId != null
        ? ref.read(occasionProvider.notifier).findById(widget.occasionId!)
        : null;
    _nameController = TextEditingController(text: occasion?.name ?? '');
    _selectedEmoji = occasion?.emoji;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  bool get _isEdit => widget.occasionId != null;

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    if (_isEdit) {
      await ref
          .read(occasionProvider.notifier)
          .update(widget.occasionId!, name, _selectedEmoji);
    } else {
      await ref
          .read(occasionProvider.notifier)
          .add(name, _selectedEmoji);
    }

    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? '用事を編集' : '用事を追加'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: const Text(
              '保存',
              style: TextStyle(
                color: AppColors.accentLight,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '用事名',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              autofocus: true,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '例: 出勤、旅行、ジム...',
              ),
              onSubmitted: (_) => _save(),
            ),
            const SizedBox(height: 24),
            Text(
              'アイコン（任意）',
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _EmojiChip(
                  emoji: null,
                  label: 'なし',
                  selected: _selectedEmoji == null,
                  onTap: () => setState(() => _selectedEmoji = null),
                ),
                ..._emojiOptions.map((e) => _EmojiChip(
                      emoji: e,
                      label: e,
                      selected: _selectedEmoji == e,
                      onTap: () => setState(() => _selectedEmoji = e),
                    )),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmojiChip extends StatelessWidget {
  const _EmojiChip({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String? emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: selected ? AppColors.accentLight : AppColors.cardBorder,
            width: 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: emoji != null ? 20 : 13,
            color: selected ? AppColors.textPrimary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
