import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../login/view model/login_vm.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/link.dart';

// [CHANGED] StatelessWidget → StatefulWidget to handle IT Management expand/collapse
class Sidebar extends StatefulWidget {
  final int selectedIndex;
  final List<String> pageRoutes;

  const Sidebar({
    super.key,
    required this.selectedIndex,
    required this.pageRoutes,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  // [NEW] expand state for IT Management submenu
  bool _isItExpanded = false;
  bool _isTicketingExpanded = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

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
                        style: TextStyle(color: Colors.white70, fontSize: 13),
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
          _menuItem(index: 0, icon: Icons.dashboard_rounded,          title: 'Dashboard',       isMobile: isMobile),
          _menuItem(index: 1, icon: Icons.people_alt_rounded,         title: 'User Management', isMobile: isMobile),
          _menuItem(index: 2, icon: Icons.workspace_premium_rounded,  title: 'Terra',           isMobile: isMobile),
          _menuItem(index: 3, icon: Icons.grid_view_rounded,          title: 'Zoho',            isMobile: isMobile),
          _menuItem(index: 4, icon: Icons.admin_panel_settings_rounded, title: 'Autocount',     isMobile: isMobile),

          // [NEW] IT Management — expandable parent item
          _itManagementItem(isMobile: isMobile),

          // [NEW] Submenu items — shown only when expanded
          if (_isItExpanded) ...[
            _subMenuItem(index: 5, title: 'Assets Inventory', isMobile: isMobile),
             _ticketingParentItem(isMobile: isMobile),
            if (_isTicketingExpanded) ...[
              _subSubMenuItem(index: 7, title: 'Incident Report', isMobile: isMobile),
              _subSubMenuItem(index: 8, title: 'Service Request',    isMobile: isMobile),
            ],
          ],
        ],
      ),
    );
  }

  // ── Regular menu item ──
  Widget _menuItem({
    required int index,
    required IconData icon,
    required String title,
    required bool isMobile,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return Link( // [NEW]
      uri: Uri.parse(widget.pageRoutes[index]),
      builder: (context, followLink) {
        return InkWell(
          onTap: followLink, // [CHANGED] dari widget.onItemSelected(index)
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 6),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white, size: isMobile ? 20 : 22),
                const SizedBox(width: 14),
                Text(title, style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        );
      },
    );
  }

  // [NEW] IT Management parent item with expand/collapse arrow
  Widget _itManagementItem({required bool isMobile}) {
    // highlight parent if any child is selected
  final bool isChildSelected =
      widget.selectedIndex == 5 ||
      widget.selectedIndex == 7 ||
      widget.selectedIndex == 8;

    return InkWell(
      onTap: () => setState(() => _isItExpanded = !_isItExpanded),
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
          // [NEW] parent stays highlighted when a child is active
          color: isChildSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.computer_rounded,
                color: Colors.white, size: isMobile ? 20 : 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                'IT Management',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // [NEW] chevron rotates when expanded
            AnimatedRotation(
              turns: _isItExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more,
                  color: Colors.white70, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  // [NEW] Submenu item — indented, dot prefix
  Widget _subMenuItem({
    required int index,
    required String title,
    required bool isMobile,
    bool comingSoon = false,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return Link( // [NEW]
      uri: Uri.parse(widget.pageRoutes[index]),
      builder: (context, followLink) {
        return InkWell(
          onTap: comingSoon ? null : followLink, // [CHANGED] dari () => widget.onItemSelected(index)
          child: Container(
            margin: EdgeInsets.only(
              left: isMobile ? 40 : 48,
              right: isMobile ? 8 : 12,
              top: 2,
              bottom: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 12 : 14,
              vertical: isMobile ? 10 : 11,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: isSelected ? 7 : 5,
                  color: isSelected ? Colors.white : Colors.white54,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: comingSoon
                        ? Colors.white38
                        : isSelected
                            ? Colors.white
                            : Colors.white70,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (comingSoon) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Soon',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _ticketingParentItem({required bool isMobile}) {
    final bool isChildSelected =
        widget.selectedIndex == 7 || widget.selectedIndex == 8;

    return InkWell(
      onTap: () => setState(() => _isTicketingExpanded = !_isTicketingExpanded),
      child: Container(
        margin: EdgeInsets.only(
          left: isMobile ? 40 : 48,
          right: isMobile ? 8 : 12,
          top: 2,
          bottom: 2,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 12 : 14,
          vertical: isMobile ? 10 : 11,
        ),
        decoration: BoxDecoration(
          color: isChildSelected
              ? Colors.white.withOpacity(0.15)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(
              Icons.circle,
              size: isChildSelected ? 7 : 5,
              color: isChildSelected ? Colors.white : Colors.white54,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Ticketing System',
                style: TextStyle(
                  color: isChildSelected ? Colors.white : Colors.white70,
                  fontSize: isMobile ? 12 : 13,
                  fontWeight: isChildSelected
                      ? FontWeight.w600
                      : FontWeight.normal,
                ),
              ),
            ),
            AnimatedRotation(
              turns: _isTicketingExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more,
                  color: Colors.white54, size: 15),
            ),
          ],
        ),
      ),
    );
  }

  // [NEW] Sub-sub menu item — further indented, for Incident Report & Side Request
  Widget _subSubMenuItem({
    required int index,
    required String title,
    required bool isMobile,
  }) {
    final bool isSelected = widget.selectedIndex == index;

    return Link( // [NEW]
      uri: Uri.parse(widget.pageRoutes[index]),
      builder: (context, followLink) {
        return InkWell(
          onTap: followLink, // [CHANGED] dari () => widget.onItemSelected(index)
          child: Container(
            margin: EdgeInsets.only(
              left: isMobile ? 58 : 68,
              right: isMobile ? 8 : 12,
              top: 2,
              bottom: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 10 : 12,
              vertical: isMobile ? 8 : 9,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.15)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: isSelected ? 5 : 4,
                  height: isSelected ? 5 : 4,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isSelected ? Colors.white : Colors.white38,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: isMobile ? 11 : 12,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}