import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AddItemField extends StatefulWidget {
  const AddItemField({super.key, required this.onAdd});

  final void Function(String name) onAdd;

  @override
  State<AddItemField> createState() => _AddItemFieldState();
}

class _AddItemFieldState extends State<AddItemField> {
  final _controller = TextEditingController();

  void _submit() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    widget.onAdd(text);
    _controller.clear();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: AppColors.textPrimary),
              decoration: const InputDecoration(
                hintText: '持ち物を追加...',
              ),
              onSubmitted: (_) => _submit(),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _submit,
            icon: const Icon(Icons.add_circle, color: AppColors.accent, size: 28),
          ),
        ],
      ),
    );
  }
}
