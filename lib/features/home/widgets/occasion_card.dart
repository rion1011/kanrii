import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/occasion.dart';

class OccasionCard extends StatelessWidget {
  const OccasionCard({
    super.key,
    required this.occasion,
    required this.itemCount,
    required this.onTap,
    required this.onLongPress,
  });

  final Occasion occasion;
  final int itemCount;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        onLongPress: onLongPress,
        borderRadius: BorderRadius.circular(12),
        splashColor: const Color(0x1AFFFFFF),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              if (occasion.emoji != null) ...[
                Text(
                  occasion.emoji!,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(width: 12),
              ] else ...[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.checklist_rounded,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      occasion.name,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'アイテム: $itemCount個',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textDisabled,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

