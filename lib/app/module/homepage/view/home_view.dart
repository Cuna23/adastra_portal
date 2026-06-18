import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../it/assets/view model/asset_vm.dart';
import '../../it/assets/view/asset_view.dart';
import '../../it/ticketing/incident/view model/incident_vm.dart';
import '../../it/ticketing/incident/view/Staff/incidentStaff_view.dart';
import '../../it/ticketing/incident/view/incidentAdmin_view.dart';
import '../../user/view model/user_vm.dart';
import '../view model/home_vm.dart';
import 'widget/sidebar.dart';
import '../../login/view model/login_vm.dart';
import '../../login/view/login_view.dart';
import '../../user/view/user_view.dart'; // adjust path if needed

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HomeViewModel(),
      child: const _HomeBody(),
    );
  }
}

// ── Separate widget so context can read HomeViewModel ──
class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final homeVm = context.watch<HomeViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),

      drawer: isMobile
          ? Drawer(
              child: Sidebar(
                selectedIndex: homeVm.selectedIndex,
                onItemSelected: (index) {
                  homeVm.selectPage(index);
                  Navigator.pop(context);
                },
              ),
            )
          : null,

      body: Row(
        children: [
          if (!isMobile)
            Sidebar(
              selectedIndex: homeVm.selectedIndex,
              onItemSelected: homeVm.selectPage,
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
                            icon: const Icon(Icons.menu,
                                color: Color(0xFF6B7280)),
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
                      icon: const Icon(Icons.logout_outlined,
                          color: Color(0xFF6B7280)),
                      onPressed: () async {
                        await authVm.logout();
                        if (context.mounted) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const LoginScreen()),
                          );
                        }
                      },
                    ),
                  ],
                ),

                Expanded(child: _buildPage(context, homeVm, authVm, isMobile)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Decides which page widget to show based on selectedIndex ──
  Widget _buildPage(
    BuildContext context,
    HomeViewModel homeVm,
    AuthViewModel authVm,
    bool isMobile,
  ) {
    switch (homeVm.selectedIndex) {
    case 1:
      return ChangeNotifierProvider(
        create: (_) => UserViewModel(),
        child: UserManagementPage(
          role: authVm.currentUser?.role ?? '',
          token: authVm.token ?? '',
        ),
      );
      case 2:
        return const Center(child: Text('Terra'));
      case 3:
        return const Center(child: Text('Zoho'));
      case 4:                                         
        return const Center(child: Text('Autocount'));
      case 5:
        return ChangeNotifierProvider(
          create: (_) => AssetViewModel(),
          child: AssetView(
            role: authVm.currentUser?.role ?? '',
            token: authVm.token ?? '',
          ),
        ); 
      case 6:
        // Ticketing System parent — non-navigable, sidebar handles expand/collapse
        return const Center(child: Text('Ticketing System'));
      case 7:
        final role = authVm.currentUser?.role.toLowerCase() ?? '';
 
        if (role == 'staff') {
          return ChangeNotifierProvider(
            create: (_) => IncidentVM(),
            child: IncidentStaffView(
              token: authVm.token ?? '',
              role: role,
            ),
          );
        }
 
        // [ADDED] Admin / Super Admin route — was previously a placeholder
        if (role == 'admin' || role == 'super_admin') {
          return ChangeNotifierProvider(
            create: (_) => IncidentVM(),
            child: IncidentAdminView(
              token: authVm.token ?? '',
              role: role,
            ),
          );
        }
 
        return const Center(child: Text('Access Denied'));
      case 8:
        return const Center(child: Text('Side Request — coming soon'));
      case 0:
      default:
        return _buildDashboard(authVm, isMobile);
    }
  }

  // ── Dashboard content — pure UI, no logic ──
  Widget _buildDashboard(AuthViewModel authVm, bool isMobile) {
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
                Icon(Icons.check_circle_outline,
                    color: Color(0xFF2E7D52), size: 20),
                SizedBox(width: 10),
                Expanded(
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
          SizedBox(height: isMobile ? 20 : 28),
          const Text(
            'Logged in as',
            style: TextStyle(color: Color(0xFF6B7280), fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            authVm.currentUser?.name ?? '—',
            style: TextStyle(
              color: const Color(0xFF1B1E28),
              fontSize: isMobile ? 18 : 22,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: isMobile ? 16 : 24),
        ],
      ),
    );
  }
}