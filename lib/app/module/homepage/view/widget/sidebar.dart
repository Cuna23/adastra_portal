import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../login/view model/login_vm.dart';
import 'package:flutter/widgets.dart';
import 'package:url_launcher/link.dart';

class Sidebar extends StatefulWidget {
  final String currentPath;

  const Sidebar({
    super.key,
    required this.currentPath,
  });

  @override
  State<Sidebar> createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  bool _isItExpanded = false;
  bool _isTicketingExpanded = false;
  // [REMOVED] _isCompanyExpanded — Company is now a single non-expandable item

  String? _role(BuildContext ctx) => ctx.watch<AuthViewModel>().currentUser?.role;

  bool _isAdminOrSuper(BuildContext ctx) =>
      _role(ctx) == 'admin' || _role(ctx) == 'super_admin';

  bool _canAccess(BuildContext ctx, String route) {
    if (_isAdminOrSuper(ctx)) return true;

    switch (route) {
      case '/dashboard':
      case '/terra':
      case '/zoho':
      case '/autocount':
      case '/incident':
      case '/service-request':
      case '/company': // [CHANGED] single route, everyone can view
        return true;
      case '/assets':
        return false;
      case '/users':
        return false;
      default:
        return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    final vm = context.watch<AuthViewModel>();
    final userName = vm.currentUser?.name;

    final canAssets = _canAccess(context, '/assets');
    final canTicketing = _canAccess(context, '/incident') || _canAccess(context, '/service-request');
    final canItManagement = canAssets || canTicketing;

    return Container(
      width: isMobile ? double.infinity : 260,
      color: const Color(0xFF005BAC),
      child: Column(
        children: [
          // Header — stays fixed, does NOT scroll
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: isMobile ? 20 : 30),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isMobile ? 20 : 24,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  child: Text(
                    (userName != null && userName.isNotEmpty) ? userName[0].toUpperCase() : '?',
                    style: TextStyle(color: Colors.white, fontSize: isMobile ? 16 : 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Hello,', style: TextStyle(color: Colors.white70, fontSize: 13)),
                      const SizedBox(height: 2),
                      Text(
                        userName ?? '—',
                        style: TextStyle(color: Colors.white, fontSize: isMobile ? 14 : 16, fontWeight: FontWeight.bold),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(color: Colors.white24, height: 1),

          // Menu list — Expanded + SingleChildScrollView fixes bottom overflow
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(top: 8, bottom: 16),
              child: Column(
                children: [
                  if (_canAccess(context, '/dashboard'))
                    _menuItem(route: '/dashboard', icon: Icons.dashboard_rounded, title: 'Dashboard', isMobile: isMobile),
                  if (_canAccess(context, '/users'))
                    _menuItem(route: '/users', icon: Icons.people_alt_rounded, title: 'User Management', isMobile: isMobile),

                  if (_canAccess(context, '/terra'))
                    _menuItem(route: '/terra', icon: Icons.workspace_premium_rounded, title: 'Terra', isMobile: isMobile),
                  if (_canAccess(context, '/zoho'))
                    _menuItem(route: '/zoho', icon: Icons.grid_view_rounded, title: 'Zoho', isMobile: isMobile),
                  if (_canAccess(context, '/autocount'))
                    _menuItem(route: '/autocount', icon: Icons.admin_panel_settings_rounded, title: 'Autocount', isMobile: isMobile),

                  if (canItManagement) _itManagementItem(isMobile: isMobile, canAssets: canAssets, canTicketing: canTicketing),

                  if (_isItExpanded) ...[
                    if (canAssets)
                      _subMenuItem(route: '/assets', title: 'Assets Inventory', isMobile: isMobile),
                    if (canTicketing) ...[
                      _ticketingParentItem(isMobile: isMobile),
                      if (_isTicketingExpanded) ...[
                        if (_canAccess(context, '/incident'))
                          _subSubMenuItem(route: '/incident', title: 'Incident Report', isMobile: isMobile),
                        if (_canAccess(context, '/service-request'))
                          _subSubMenuItem(route: '/service-request', title: 'Service Request', isMobile: isMobile),
                      ],
                    ],
                  ],

                  // [CHANGED] Company — single non-expandable item, bottom of list
                  if (_canAccess(context, '/company'))
                    _menuItem(route: '/company', icon: Icons.apartment_rounded, title: 'Company', isMobile: isMobile),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required String route,
    required IconData icon,
    required String title,
    required bool isMobile,
  }) {
    final bool isSelected = widget.currentPath == route;

    return Link(
      uri: Uri.parse(route),
      builder: (context, followLink) {
        return InkWell(
          onTap: followLink,
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

  Widget _itManagementItem({required bool isMobile, required bool canAssets, required bool canTicketing}) {
    final bool isChildSelected =
        (canAssets && widget.currentPath == '/assets') ||
        (canTicketing && (widget.currentPath == '/incident' || widget.currentPath == '/service-request'));

    return InkWell(
      onTap: () => setState(() => _isItExpanded = !_isItExpanded),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: isMobile ? 8 : 12, vertical: isMobile ? 4 : 6),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 16, vertical: isMobile ? 12 : 14),
        decoration: BoxDecoration(
          color: isChildSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(Icons.computer_rounded, color: Colors.white, size: isMobile ? 20 : 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text('IT Management',
                  style: TextStyle(color: Colors.white, fontSize: isMobile ? 13 : 14, fontWeight: FontWeight.w500)),
            ),
            AnimatedRotation(
              turns: _isItExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more, color: Colors.white70, size: 18),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subMenuItem({
    required String route,
    required String title,
    required bool isMobile,
    bool comingSoon = false,
  }) {
    final bool isSelected = widget.currentPath == route;

    return Link(
      uri: Uri.parse(route),
      builder: (context, followLink) {
        return InkWell(
          onTap: comingSoon ? null : followLink,
          child: Container(
            margin: EdgeInsets.only(left: isMobile ? 40 : 48, right: isMobile ? 8 : 12, top: 2, bottom: 2),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 11),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.circle, size: isSelected ? 7 : 5, color: isSelected ? Colors.white : Colors.white54),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: comingSoon ? Colors.white38 : (isSelected ? Colors.white : Colors.white70),
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                if (comingSoon) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
                    child: const Text('Soon', style: TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.w600)),
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
        widget.currentPath == '/incident' || widget.currentPath == '/service-request';

    return InkWell(
      onTap: () => setState(() => _isTicketingExpanded = !_isTicketingExpanded),
      child: Container(
        margin: EdgeInsets.only(left: isMobile ? 40 : 48, right: isMobile ? 8 : 12, top: 2, bottom: 2),
        padding: EdgeInsets.symmetric(horizontal: isMobile ? 12 : 14, vertical: isMobile ? 10 : 11),
        decoration: BoxDecoration(
          color: isChildSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Icon(Icons.circle, size: isChildSelected ? 7 : 5, color: isChildSelected ? Colors.white : Colors.white54),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Ticketing System',
                  style: TextStyle(
                    color: isChildSelected ? Colors.white : Colors.white70,
                    fontSize: isMobile ? 12 : 13,
                    fontWeight: isChildSelected ? FontWeight.w600 : FontWeight.normal,
                  )),
            ),
            AnimatedRotation(
              turns: _isTicketingExpanded ? 0.5 : 0,
              duration: const Duration(milliseconds: 200),
              child: const Icon(Icons.expand_more, color: Colors.white54, size: 15),
            ),
          ],
        ),
      ),
    );
  }

  Widget _subSubMenuItem({
    required String route,
    required String title,
    required bool isMobile,
  }) {
    final bool isSelected = widget.currentPath == route;

    return Link(
      uri: Uri.parse(route),
      builder: (context, followLink) {
        return InkWell(
          onTap: followLink,
          child: Container(
            margin: EdgeInsets.only(left: isMobile ? 58 : 68, right: isMobile ? 8 : 12, top: 2, bottom: 2),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 10 : 12, vertical: isMobile ? 8 : 9),
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.15) : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Container(
                  width: isSelected ? 5 : 4,
                  height: isSelected ? 5 : 4,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: isSelected ? Colors.white : Colors.white38),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.white54,
                    fontSize: isMobile ? 11 : 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
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