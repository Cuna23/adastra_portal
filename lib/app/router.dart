import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'common/widgets/external_system_frame.dart';
import 'module/company/view model/comp_vm.dart';
import 'module/company/view/comp_view.dart';
import 'module/dashboard/view model/dash_vm.dart';
import 'module/dashboard/view/dashAdmin_view.dart';
import 'module/dashboard/view/dashStaff_view.dart';
import 'module/homepage/view/home_view.dart';
import 'module/it/ticketing/sr/view model/sr_vm.dart';
import 'module/it/ticketing/sr/view/srAdmin_view.dart';
import 'module/it/ticketing/sr/view/srStaff_view.dart';
import 'module/login/view model/login_vm.dart';
import 'module/login/view/auth_success_view.dart';
import 'module/login/view/login_view.dart';
import 'module/it/assets/view/asset_view.dart';
import 'module/it/assets/view model/asset_vm.dart';
import 'module/it/ticketing/incident/view/incidentStaff_view.dart';
import 'module/it/ticketing/incident/view/incidentAdmin_view.dart';
import 'module/it/ticketing/incident/view model/incident_vm.dart';
import 'module/user/view/user_view.dart';
import 'module/user/view model/user_vm.dart';

GoRouter buildRouter(AuthViewModel authVm) {
  return GoRouter(
    initialLocation: '/dashboard',
    refreshListenable: authVm, // [NEW] router rebuild bila auth state berubah
    redirect: (context, state) {
      final loggedIn = authVm.token != null;
      final loggingIn = state.matchedLocation == '/login';
      final authSuccess = state.matchedLocation == '/auth-success';

      if (!loggedIn && !loggingIn && !authSuccess) return '/login';
      if (loggedIn && loggingIn) return '/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(
        path: '/auth-success',
        builder: (context, state) {
          final token = state.uri.queryParameters['token'];
          return AuthSuccessScreen(token: token);
        },
      ),

      ShellRoute(
        builder: (context, state, child) => HomeShell(child: child),
        routes: [
          GoRoute(
            path: '/dashboard',
            builder: (_, __) {
              final role = authVm.currentUser?.role.toLowerCase() ?? '';
              return ChangeNotifierProvider(
                create: (_) => DashboardViewModel(),
                child: role == 'staff'
                    ? DashboardStaffView(token: authVm.token ?? '')
                    : DashboardAdminView(token: authVm.token ?? ''),
              );
            },
          ),
          GoRoute(
            path: '/users',
            builder: (_, __) => ChangeNotifierProvider(
              create: (_) => UserViewModel(),
              child: UserManagementPage(
                role: authVm.currentUser?.role ?? '',
                token: authVm.token ?? '',
              ),
            ),
          ),
          GoRoute(
            path: '/terra',
            builder: (_, __) => const ExternalSystemFrame(
              systemKey: 'terra',
              systemName: 'Terra',
              url: 'https://practicetestautomation.com/practice-test-login/',
              embeddable: true,
            ),
          ),
          GoRoute(
            path: '/zoho',
            builder: (_, __) => const ExternalSystemFrame(
              systemKey: 'zoho',
              systemName: 'Zoho',
              url: 'https://accounts.zoho.com/signin',
              embeddable: false,
              icon: Icons.grid_view_rounded,
              accentColor: Color(0xFFE42527),
              description: 'Log in using your Zoho account.',
            ),
          ),
          GoRoute(
            path: '/autocount',
            builder: (_, __) => const ExternalSystemFrame(
              systemKey: 'autocount',
              systemName: 'AutoCount',
              url: 'https://auth.autocountcloud.com/identity/account/login/payroll',
              embeddable: false,
              icon: Icons.admin_panel_settings_rounded,
              accentColor: Color(0xFF185FA5),
              description: 'Log in using your AutoCount account.',
            ),
          ),
          GoRoute(
            path: '/assets',
            builder: (_, __) => ChangeNotifierProvider(
              create: (_) => AssetViewModel(),
              child: AssetView(
                role: authVm.currentUser?.role ?? '',
                token: authVm.token ?? '',
              ),
            ),
          ),
          GoRoute(path: '/ticketing', builder: (_, __) => const Center(child: Text('Ticketing System'))),
          GoRoute(
            path: '/incident',
            builder: (_, __) {
              final role = authVm.currentUser?.role.toLowerCase() ?? '';
              if (role == 'staff') {
                return ChangeNotifierProvider(
                  create: (_) => IncidentVM(),
                  child: IncidentStaffView(
                    token: authVm.token ?? '',
                    role: role,
                    currentUserId: authVm.currentUser?.id ?? 0,
                  ),
                );
              }
              if (role == 'admin' || role == 'super_admin') {
                return ChangeNotifierProvider(
                  create: (_) => IncidentVM(),
                  child: IncidentAdminView(
                    token: authVm.token ?? '',
                    role: role,
                    currentUserId: authVm.currentUser?.id ?? 0,
                  ),
                );
              }
              return const Center(child: Text('Access Denied'));
            },
          ),
          GoRoute(
            path: '/service-request',
            builder: (_, __) {
              final role = authVm.currentUser?.role.toLowerCase() ?? '';
              if (role == 'staff') {
                return ChangeNotifierProvider(
                  create: (_) => ServiceRequestViewModel(),
                  child: ServiceRequestStaffView(
                    token: authVm.token ?? '',
                    role: role,
                    currentUserId: authVm.currentUser?.id ?? 0,
                  ),
                );
              }
              if (role == 'admin' || role == 'super_admin') {
                return ChangeNotifierProvider(
                  create: (_) => ServiceRequestViewModel(),
                  child: ServiceRequestAdminView(
                    token: authVm.token ?? '',
                    role: role,
                    currentUserId: authVm.currentUser?.id ?? 0,
                  ),
                );
              }
              return const Center(child: Text('Access Denied'));
            },
          ),
          GoRoute(
            path: '/company',
            builder: (_, __) => ChangeNotifierProvider(
              create: (_) => CompanyViewModel(),
              child: CompanyView(
                role: authVm.currentUser?.role ?? '',
                token: authVm.token ?? '',
              ),
            ),
          ),
        ],
      ),
    ],
  );
}