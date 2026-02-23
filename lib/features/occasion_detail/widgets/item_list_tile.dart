import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../models/item.dart';

class ItemListTile extends StatelessWidget {
  const ItemListTile({
    super.key,
    required this.item,
    required this.onDelete,
  });

  final Item item;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key('dismissible_${item.id}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.deleteRed,
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      onDismissed: (_) => onDelete(),
      child: Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: AppColors.divider, width: 0.5),
          ),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
          title: Text(
            item.name,
            style: const TextStyle(color: AppColors.textPrimary),
          ),
          trailing: IconButton(
            icon: const Icon(Icons.close,
                color: AppColors.textDisabled, size: 18),
            onPressed: onDelete,
          ),
        ),
      ),
    );
  }
}
