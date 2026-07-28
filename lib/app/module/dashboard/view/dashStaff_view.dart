import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../view model/dash_vm.dart';
import '../../login/view model/login_vm.dart';

class DashboardStaffView extends StatefulWidget {
  final String token;
  const DashboardStaffView({super.key, required this.token});

  @override
  State<DashboardStaffView> createState() => _DashboardStaffViewState();
}

class _DashboardStaffViewState extends State<DashboardStaffView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchStaff(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (vm.isLoading && vm.staffStats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final stats = vm.staffStats;
    if (stats == null) {
      return const Center(child: Text('Failed to load dashboard.'));
    }

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 16 : 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Hello, ${authVm.currentUser?.name ?? '—'}',
              style: TextStyle(fontSize: isMobile ? 18 : 22, fontWeight: FontWeight.w700, color: const Color(0xFF1B1E28))),
          const SizedBox(height: 4),
          const Text('Here is a summary of your own tickets and requests.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricCard('My open incidents', stats.myOpenIncidents, isMobile),
              _metricCard('My pending requests', stats.myPendingRequests, isMobile),
              _metricCard('Assets assigned to me', stats.myAssets, isMobile),
            ],
          ),
          const SizedBox(height: 20),

          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('My recent tickets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                const SizedBox(height: 12),
                if (stats.recentTickets.isEmpty)
                  const Text('No tickets yet.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1)))
                else
                  ...stats.recentTickets.map((t) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(t.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)), overflow: TextOverflow.ellipsis),
                            ),
                            _statusBadge(t.status),
                          ],
                        ),
                      )),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text('Quick actions', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _actionCard(Icons.add_alert_outlined, 'Report an incident', () => context.go('/incident')),
              _actionCard(Icons.playlist_add_rounded, 'New service request', () => context.go('/service-request')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _metricCard(String label, int value, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
          const SizedBox(height: 4),
          Text('$value', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Color(0xFF1B1E28))),
        ],
      ),
    );
  }

  Widget _statusBadge(String status) {
    final colors = {
      'open': const Color(0xFF185FA5), 'in progress': const Color(0xFF854F0B),
      'resolved': const Color(0xFF3B6D11), 'pending': const Color(0xFF185FA5),
      'approved': const Color(0xFF3B6D11), 'rejected': const Color(0xFFD64545),
    };
    final bg = {
      'open': const Color(0xFFE6F1FB), 'in progress': const Color(0xFFFAEEDA),
      'resolved': const Color(0xFFEAF3DE), 'pending': const Color(0xFFE6F1FB),
      'approved': const Color(0xFFEAF3DE), 'rejected': const Color(0xFFFDEDED),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg[status] ?? const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(20)),
      child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors[status] ?? const Color(0xFF6B7280))),
    );
  }

  Widget _actionCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E9F0)), borderRadius: BorderRadius.circular(10)),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF185FA5)),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)))),
          ],
        ),
      ),
    );
  }
}