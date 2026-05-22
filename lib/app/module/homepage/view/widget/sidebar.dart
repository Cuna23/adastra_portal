import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../login/view model/login_vm.dart'; // adjust path if needed

class Sidebar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemSelected;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.onItemSelected,
    // ── REMOVED: userName parameter — ViewModel reads it directly ──
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    // ── ADDED: read from ViewModel directly, MVVM pattern ──
    final vm = context.watch<AuthViewModel>();
    final userName = vm.currentUser?.name;

    return Container(
      width: isMobile ? double.infinity : 260,
      color: const Color(0xFF005BAC),
      child: Column(
        children: [
          // Header — user greeting
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: isMobile ? 20 : 30,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 20 : 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (userName != null && userName.isNotEmpty)
                        ? userName[0].toUpperCase()
                        : '?',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isMobile ? 16 : 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hello,',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        userName ?? '—',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24),

          // Menu Items
          _menuItem(index: 0, icon: Icons.dashboard_rounded, title: 'Dashboard', isMobile: isMobile),
          _menuItem(index: 1, icon: Icons.people_alt_rounded, title: 'User Management', isMobile: isMobile),
          _menuItem(index: 2, icon: Icons.workspace_premium_rounded, title: 'Trademark Management', isMobile: isMobile),
          _menuItem(index: 3, icon: Icons.grid_view_rounded, title: 'Pattern Management', isMobile: isMobile),
        ],
      ),
    );
  }

  Widget _menuItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isMobile,
  }) {
    final bool isSelected = selectedIndex == index;

    return InkWell(
      onTap: () => onItemSelected(index),
      child: Container(
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? 8 : 12,
          vertical: isMobile ? 4 : 6,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 16,
          vertical: isMobile ? 12 : 14,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: isMobile ? 20 : 22),
            const SizedBox(width: 14),
            Text(
              title,
              style: TextStyle(
                color: Colors.white,
                fontSize: isMobile ? 13 : 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}