import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppsHomeView extends StatelessWidget {
  const AppsHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 20 : 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Apps', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
          const Text('External systems connected to the portal', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 24),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: _appCard(
                  icon: Icons.workspace_premium_rounded,
                  cardColor: const Color(0xFFF3EEFF),
                  iconColor: const Color(0xFF6D28D9),
                  title: 'Terra',
                  onTap: () => context.go('/terra'),
                ),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: _appCard(
                  icon: Icons.grid_view_rounded,
                  cardColor: const Color(0xFFFDECEC),
                  iconColor: const Color(0xFFE42527),
                  title: 'Zoho',
                  onTap: () => context.go('/zoho'),
                ),
              ),
              SizedBox(
                width: 150,
                height: 150,
                child: _appCard(
                  icon: Icons.admin_panel_settings_rounded,
                  cardColor: const Color(0xFFE6F1FB),
                  iconColor: const Color(0xFF185FA5),
                  title: 'Autocount',
                  onTap: () => context.go('/autocount'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _appCard({
    required IconData icon,
    required Color cardColor,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: iconColor.withOpacity(0.15)),
        ),
        padding: const EdgeInsets.all(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
              child: Icon(icon, size: 28, color: iconColor),
            ),
            const SizedBox(height: 10),
            Text(title, textAlign: TextAlign.center, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700, color: iconColor.withOpacity(0.9))),
          ],
        ),
      ),
    );
  }
}