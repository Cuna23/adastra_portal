import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // [NEW]
import 'package:provider/provider.dart';
import '../view model/home_vm.dart';
import 'widget/sidebar.dart';
import '../../login/view model/login_vm.dart';
import '../../login/view/login_view.dart';

// [CHANGED] HomeScreen -> HomeShell, terima child widget dari ShellRoute
class HomeShell extends StatelessWidget {
  final Widget child; // [NEW]
  const HomeShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: _HomeBody(child: child), // [CHANGED] pass child through
    );
  }
}

class _HomeBody extends StatelessWidget {
  final Widget child; // [NEW]
  const _HomeBody({required this.child});

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    // [NEW] sync sidebar highlight ikut current URL, bukan manual index setting
    final currentPath = GoRouterState.of(context).matchedLocation;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      homeVm.selectPageFromRoute(currentPath);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: homeVm.selectedIndex,
                pageRoutes: homeVm.pageRoutes, // [NEW]
              ),
            )
          : null,
      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              selectedIndex: homeVm.selectedIndex,
              pageRoutes: homeVm.pageRoutes, // [NEW]
            ),
          Expanded(
            child: Column(
              children: [
                AppBar(
                  backgroundColor: Colors.white,
                  elevation: 0,
                  automaticallyImplyLeading: isMobile,
                  leading: isMobile
                      ? Builder(
                          builder: (ctx) => IconButton(
                            icon: const Icon(Icons.menu, color: Color(0xFF6B7280)),
                            onPressed: () => Scaffold.of(ctx).openDrawer(),
                          ),
                        )
                      : null,
                  title: Text(
                    homeVm.currentPageTitle,
                    style: TextStyle(
                      color: const Color(0xFF1B1E28),
                      fontSize: isMobile ? 14 : 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.logout_outlined, color: Color(0xFF6B7280)),
                      onPressed: () async {
                        await authVm.logout();
                        if (context.mounted) context.go('/login'); // [CHANGED]
                      },
                    ),
                  ],
                ),
                Expanded(child: child), // [CHANGED] terus render child dari router
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// [NEW] Dashboard body dipisah keluar sebagai widget sendiri (dulu _buildDashboard)
class DashboardBody extends StatelessWidget {
  const DashboardBody({super.key});

  @override
  Widget build(BuildContext context) {
    final authVm = context.watch<AuthViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FBF4),
              border: Border.all(color: const Color(0xFFBBE5C8)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Color(0xFF2E7D52), size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Backend connected successfully!',
                    style: TextStyle(color: Color(0xFF2E7D52), fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: isMobile ? 20 : 28),
          const Text('Logged in as', style: TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          const SizedBox(height: 4),
          Text(
            authVm.currentUser?.name ?? '—',
            style: TextStyle(color: const Color(0xFF1B1E28), fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: isMobile ? 16 : 24),
        ],
      ),
    );
  }
}