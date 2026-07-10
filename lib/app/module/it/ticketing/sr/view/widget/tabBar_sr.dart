import 'package:flutter/material.dart';

class StatusTabBarSR extends StatelessWidget {
  final String selected;
  final int countAll;
  final int countPending;
  final int countApproved;
  final int countRejected;
  final void Function(String status) onSelect;

  const StatusTabBarSR({
    super.key,
    required this.selected,
    required this.countAll,
    required this.countPending,
    required this.countApproved,
    required this.countRejected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final filters = [
      ('All', countAll),
      ('Pending', countPending),
      ('Approved', countApproved),
      ('Rejected', countRejected),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          return _Tab(
            label: f.$1,
            count: f.$2,
            selected: selected == f.$1,
            onTap: () => onSelect(f.$1),
          );
        }).toList(),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  static const _brandBlue   = Color(0xFF185FA5);
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);

  const _Tab({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : _textPrimary,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.2)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white : _textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}