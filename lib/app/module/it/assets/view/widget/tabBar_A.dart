import 'package:flutter/material.dart';
import '../../model/assetCategory_model.dart';

// ═══════════════════════════════════════════════════════════════════════════════
// Category Tab Bar
// ═══════════════════════════════════════════════════════════════════════════════

class CategoryTabBarA extends StatelessWidget {
  final List<AssetCategoryModel> categories;
  final int? selectedId;
  final void Function(int? id) onSelect;

  const CategoryTabBarA({
    super.key,
    required this.categories,
    required this.selectedId,
    required this.onSelect,
  });

  IconData _iconFor(String name) {
    final n = name.toLowerCase();
    if (n.contains('computer') || n.contains('laptop')) return Icons.laptop_mac_outlined;
    if (n.contains('phone') || n.contains('mobile'))    return Icons.smartphone_outlined;
    if (n.contains('network') || n.contains('router'))  return Icons.router_outlined;
    if (n.contains('printer'))                          return Icons.print_outlined;
    if (n.contains('monitor') || n.contains('display')) return Icons.monitor_outlined;
    if (n.contains('software'))                         return Icons.window_outlined;
    return Icons.devices_other_outlined;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        children: [
          _Tab(
            label: 'All',
            icon: Icons.widgets_outlined,
            selected: selectedId == null,
            onTap: () => onSelect(null),
          ),
          ...categories.map(
            (c) => _Tab(
              label: c.name,
              icon: _iconFor(c.name),
              selected: selectedId == c.id,
              onTap: () => onSelect(c.id),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// Single Tab
// ═══════════════════════════════════════════════════════════════════════════════

class _Tab extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  static const _brandBlue   = Color(0xFF185FA5);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);

  const _Tab({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6, bottom: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
        decoration: BoxDecoration(
          color: selected ? _brandBlue : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? _brandBlue : _borderColor,
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: selected ? Colors.white : _textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : _textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}