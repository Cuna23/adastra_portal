import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
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
          GoRoute(path: '/dashboard', builder: (_, __) => const DashboardBody()),
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
          GoRoute(path: '/terra', builder: (_, __) => const Center(child: Text('Terra'))),
          GoRoute(path: '/zoho', builder: (_, __) => const Center(child: Text('Zoho'))),
          GoRoute(path: '/autocount', builder: (_, __) => const Center(child: Text('Autocount'))),
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
        ],
      ),
    ],
  );
}