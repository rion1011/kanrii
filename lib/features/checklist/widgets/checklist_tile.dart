import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/item.dart';

class ChecklistTile extends StatelessWidget {
  const ChecklistTile({
    super.key,
    required this.item,
    required this.checked,
    required this.onToggle,
  });

  final Item item;
  final bool checked;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onToggle,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Row(
          children: [
            Checkbox(
              value: checked,
              onChanged: (_) => onToggle(),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  fontSize: 16,
                  color: checked
                      ? AppColors.textDisabled
                      : AppColors.textPrimary,
                  decoration: checked
                      ? TextDecoration.lineThrough
                      : TextDecoration.none,
                  decorationColor: AppColors.textDisabled,
                ),
                child: Opacity(
                  opacity: checked ? 0.5 : 1.0,
                  child: Text(item.name),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
