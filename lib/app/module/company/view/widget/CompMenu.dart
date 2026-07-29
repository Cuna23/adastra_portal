import 'package:flutter/material.dart';

class CompMenu extends StatelessWidget {
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool deleteEnabled;

  const CompMenu({
    super.key,
    this.onEdit,
    this.onDelete,
    this.deleteEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (onEdit == null && onDelete == null) return const SizedBox.shrink();
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded, size: 18, color: Color(0xFF6B7280)),
      splashRadius: 18,
      color: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      onSelected: (value) {
        if (value == 'edit') onEdit?.call();
        if (value == 'delete' && deleteEnabled) onDelete?.call();
      },
      itemBuilder: (context) => [
        if (onEdit != null)
          const PopupMenuItem(
            value: 'edit',
            child: Row(
              children: [
                Icon(Icons.edit_outlined, size: 15, color: Color(0xFF185FA5)),
                SizedBox(width: 8),
                Text('Edit', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Color(0xFF1B1E28))),
              ],
            ),
          ),
        if (onDelete != null)
          PopupMenuItem(
            value: 'delete',
            enabled: deleteEnabled, // [NEW] grayed out + tak boleh klik untuk admin
            child: Row(
              children: [
                Icon(Icons.delete_outline, size: 15, color: deleteEnabled ? const Color(0xFFD92D20) : const Color(0xFFB9C1CC)),
                const SizedBox(width: 8),
                Text(
                  'Delete',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: deleteEnabled ? const Color(0xFFD92D20) : const Color(0xFFB9C1CC),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}