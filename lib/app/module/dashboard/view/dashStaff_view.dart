import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../model/dash_model.dart';
import '../view model/dash_vm.dart';
import '../../login/view model/login_vm.dart';
import 'widget/calendar.dart';

class DashboardStaffView extends StatefulWidget {
  final String token;
  const DashboardStaffView({super.key, required this.token});

  @override
  State<DashboardStaffView> createState() => _DashboardStaffViewState();
}

class _DashboardStaffViewState extends State<DashboardStaffView> {
  static const _brand = Color(0xFF185FA5);

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
          const Text('Here is a summary of your own tickets and requests.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _themedMetricCard('My open incidents', stats.myOpenIncidents, const Color(0xFF185FA5), const Color(0xFFE6F1FB), isMobile),
              _themedMetricCard('My pending requests', stats.myPendingRequests, const Color(0xFF0F6E56), const Color(0xFFE1F5EE), isMobile),
              _themedMetricCard('Assets assigned to me', stats.myAssets, const Color(0xFF4F46E5), const Color(0xFFEEF2FF), isMobile),
            ],
          ),
          const SizedBox(height: 20),

          isMobile
            ? Column(
              children: [
                _recentTicketsCard(context, stats),
                const SizedBox(height: 16),
                CalendarWidget(token: widget.token),
                ],
              )
              : IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(flex: 5, child: _recentTicketsCard(context, stats)),
                    const SizedBox(width: 16),
                    Expanded(flex: 5, child: CalendarWidget(token: widget.token)),
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
              _quickActionCard(Icons.add_alert_outlined, 'Report an incident', () => context.go('/incident?new=true')),
              _quickActionCard(Icons.playlist_add_rounded, 'New service request', () => context.go('/service-request?new=true')),
            ],
          ),
        ],
      ),
    );
  }

  // ── Metric card — bertema, sama gaya dengan admin ──
  Widget _themedMetricCard(String label, int value, Color fg, Color bg, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 180,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: fg.withOpacity(0.3), width: 0.8),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 3, offset: const Offset(0, 1))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: fg)),
          const SizedBox(height: 4),
          Text('$value', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: fg)),
        ],
      ),
    );
  }

  // ── Recent tickets — accent bar + divider + clickable, sama gaya dengan needs attention admin ──
  Widget _recentTicketsCard(BuildContext context, StaffDashboardStats stats) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('My recent tickets', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
          const SizedBox(height: 8),
          if (stats.recentTickets.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('No tickets yet.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))))
          else
            Column(
              children: List.generate(stats.recentTickets.length, (i) {
                final t = stats.recentTickets[i];
                final isLast = i == stats.recentTickets.length - 1;
                return InkWell(
                  onTap: () => context.go(t.type == 'incident' ? '/incident' : '/service-request'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE5E9F0), width: 0.5))),
                    child: Row(
                      children: [
                        Container(width: 3, height: 30, decoration: BoxDecoration(color: _statusColor(t.status), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)), overflow: TextOverflow.ellipsis, maxLines: 1),
                        ),
                        const SizedBox(width: 8),
                        _statusBadge(t.status),
                      ],
                    ),
                  ),
                );
              }),
            ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'open':
      case 'pending':
        return const Color(0xFF185FA5);
      case 'in progress':
        return const Color(0xFF854F0B);
      case 'resolved':
      case 'approved':
        return const Color(0xFF3B6D11);
      case 'rejected':
        return const Color(0xFFD64545);
      default:
        return const Color(0xFF9AA5B1);
    }
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

  // ── Quick action — sama gaya dengan admin quick access (border + shadow) ──
  Widget _quickActionCard(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 200,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xFFE5E9F0), width: 1),
          borderRadius: BorderRadius.circular(10),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: _brand),
            const SizedBox(width: 10),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)))),
          ],
        ),
      ),
    );
  }
}