import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'widget/sidebar.dart';
import '../../login/view model/login_vm.dart';
import '../../login/view/login_view.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ── CHANGED: added responsive variables ──
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Consumer<AuthViewModel>(
      builder: (context, vm, _) {
        final user = vm.currentUser;

        return Scaffold(
          backgroundColor: const Color(0xFFF4F7FC),

          // ── CHANGED: on mobile, use Drawer for sidebar instead of side-by-side Row ──
          drawer: isMobile
              ? Drawer(
                  child: Sidebar(
                    selectedIndex: 0,
                    onItemSelected: (index) {
                      Navigator.pop(context);
                    },
                  ),
                )
              : null,

          body: Row(
            children: [
              // ── CHANGED: hide sidebar on mobile (use drawer instead) ──
              if (!isMobile)
                Sidebar(
                  selectedIndex: 0,
                  onItemSelected: (index) {},
                ),

              // ───────────────── MAIN CONTENT ─────────────────
              Expanded(
                child: Column(
                  children: [
                    // ───────────────── APP BAR ─────────────────
                    AppBar(
                      backgroundColor: Colors.white,
                      elevation: 0,
                      // ── CHANGED: show hamburger on mobile to open drawer ──
                      automaticallyImplyLeading: isMobile,
                      leading: isMobile
                          ? Builder(
                              builder: (context) => IconButton(
                                icon: const Icon(
                                  Icons.menu,
                                  color: Color(0xFF6B7280),
                                ),
                                onPressed: () =>
                                    Scaffold.of(context).openDrawer(),
                              ),
                            )
                          : null,
                      title: Text(
                        'Dashboard',
                        style: TextStyle(
                          color: const Color(0xFF1B1E28),
                          // ── CHANGED: smaller font on mobile ──
                          fontSize: isMobile ? 14 : 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(
                            Icons.logout_outlined,
                            color: Color(0xFF6B7280),
                          ),
                          onPressed: () async {
                            await vm.logout();

                            if (context.mounted) {
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const LoginScreen(),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),

                    // ───────────────── BODY ─────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        // ── CHANGED: smaller padding on mobile ──
                        padding: EdgeInsets.all(isMobile ? 16 : 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [

                            // Success banner
                            Container(
                              // ── CHANGED: smaller padding on mobile ──
                              padding: EdgeInsets.all(isMobile ? 12 : 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF0FBF4),
                                border: Border.all(
                                  color: const Color(0xFFBBE5C8),
                                ),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.check_circle_outline,
                                    color: Color(0xFF2E7D52),
                                    size: 20,
                                  ),

                                  const SizedBox(width: 10),

                                  // ── CHANGED: Expanded so text wraps on small screens ──
                                  const Expanded(
                                    child: Text(
                                      'Backend connected successfully!',
                                      style: TextStyle(
                                        color: Color(0xFF2E7D52),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── CHANGED: smaller gap on mobile ──
                            SizedBox(height: isMobile ? 20 : 28),

                            const Text(
                              'Logged in as',
                              style: TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 13,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              user?.name ?? '—',
                              style: TextStyle(
                                color: const Color(0xFF1B1E28),
                                // ── CHANGED: smaller font on mobile ──
                                fontSize: isMobile ? 18 : 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),

                            // ── CHANGED: smaller gap on mobile ──
                            SizedBox(height: isMobile ? 16 : 24),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _truncate(String? token) {
    if (token == null) return '—';
    return token.length > 30 ? '${token.substring(0, 30)}…' : token;
  }

  // ── CHANGED: added isMobile parameter ──
  Widget _infoCard(String label, String value, IconData icon, bool isMobile) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        // ── CHANGED: smaller padding on mobile ──
        horizontal: isMobile ? 12 : 16,
        vertical: isMobile ? 10 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFFFF),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF005BAC), size: 20),
          const SizedBox(width: 12),

          // ── CHANGED: Expanded so long values don't overflow ──
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 12)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    color: const Color(0xFF1B1E28),
                    // ── CHANGED: slightly smaller on mobile ──
                    fontSize: isMobile ? 13 : 14,
                  ),
                  // ── CHANGED: prevent long token from overflowing ──
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}