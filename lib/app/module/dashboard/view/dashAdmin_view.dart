import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/dash_model.dart';
import '../view model/dash_vm.dart';
import '../../login/view model/login_vm.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

import 'widget/calendar.dart';

class DashboardAdminView extends StatefulWidget {
  final String token;
  const DashboardAdminView({super.key, required this.token});

  @override
  State<DashboardAdminView> createState() => _DashboardAdminViewState();
}

class _DashboardAdminViewState extends State<DashboardAdminView> {
  static const _brand = Color(0xFF185FA5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardViewModel>().fetchAdmin(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<DashboardViewModel>();
    final authVm = context.watch<AuthViewModel>();
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;
    final isNarrow = width < 700;

    if (vm.isLoading && vm.adminStats == null) {
      return const Center(child: CircularProgressIndicator());
    }
    final stats = vm.adminStats;
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
          const Text('Here is what is happening across the portal today.', style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _severityMetricCard('Open incidents', stats.openIncidents, isMobile),
              _severityMetricCard('Pending requests', stats.pendingRequests, isMobile),
              _neutralMetricCard('Total assets', stats.totalAssets, const Color(0xFF185FA5), const Color(0xFFE6F1FB), isMobile),
              _neutralMetricCard('Active staff', stats.activeStaff, const Color(0xFF4F46E5), const Color(0xFFEEF2FF), isMobile),
            ],
          ),
          const SizedBox(height: 20),

          isNarrow
              ? Column(
                  children: [
                    _incidentsDonutCard(stats, isMobile),
                    const SizedBox(height: 16),
                    CalendarWidget(token: widget.token),
                    const SizedBox(height: 16),
                    _needsAttentionCard(stats, isMobile, compact: true),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 6, child: _incidentsDonutCard(stats, isMobile)),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CalendarWidget(token: widget.token),
                            const SizedBox(height: 16),
                            _needsAttentionCard(stats, isMobile, compact: true),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
          const SizedBox(height: 20),

          const Text('Quick access', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
          const SizedBox(height: 10),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _quickAccessCard(Icons.report_problem_outlined, 'Incidents', '${stats.openIncidents} open', () => context.go('/incident')),
              _quickAccessCard(Icons.assignment_outlined, 'Service requests', '${stats.pendingRequests} pending', () => context.go('/service-request')),
              _quickAccessCard(Icons.devices_other_outlined, 'Asset inventory', '${stats.totalAssets} items', () => context.go('/assets')),
              _quickAccessCard(Icons.people_alt_outlined, 'User management', '${stats.activeStaff} staff', () => context.go('/users')),
            ],
          ),
        ],
      ),
    );
  }

  // ── Metric cards ──
  Widget _severityMetricCard(String label, int value, bool isMobile) {
    Color fg, bg, border;
    if (value > 10) {
      fg = const Color(0xFFA32D2D);
      bg = const Color(0xFFFDECEC);
      border = const Color(0xFFD64545);
    } else if (value >= 5) {
      fg = const Color(0xFF854F0B);
      bg = const Color(0xFFFAEEDA);
      border = const Color(0xFFEDDBB0);
    } else {
      fg = const Color(0xFF3B6D11);
      bg = const Color(0xFFEAF3DE);
      border = const Color(0xFFC9DFAA);
    }

    return Container(
      width: isMobile ? double.infinity : 170,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: 0.8),
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

  Widget _neutralMetricCard(String label, int value, Color fg, Color bg, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 170,
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

  // ── Donut chart ──
  Widget _incidentsDonutCard(AdminDashboardStats stats, bool isMobile) {
    final entries = stats.incidentsByStatus.entries.toList();
    final colors = {'Open': const Color(0xFFEB6834), 'In pending': const Color(0xFFEDA100), 'Resolved': const Color(0xFF008300)};
    final total = entries.fold<int>(0, (sum, e) => sum + e.value);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Incidents by status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
          Text('This month — $total total tickets', style: const TextStyle(fontSize: 11, color: Color(0xFF9AA5B1))),
          const SizedBox(height: 16),
          Expanded(
            child: total == 0
                ? const Center(child: Text('No incidents yet.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))))
                : Center(
                    child: PieChart(
                      PieChartData(
                        sectionsSpace: 2,
                        centerSpaceRadius: 60,
                        sections: entries
                            .where((e) => e.value > 0)
                            .map((e) => PieChartSectionData(
                                  value: e.value.toDouble(),
                                  color: colors[e.key] ?? _brand,
                                  title: '${e.value}',
                                  radius: 55, // [FIX] dibesarkan dari 45
                                  titleStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white),
                                ))
                            .toList(),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 16,
              runSpacing: 6,
              children: entries.map((e) {
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(width: 8, height: 8, decoration: BoxDecoration(color: colors[e.key] ?? _brand, borderRadius: BorderRadius.circular(2))),
                    const SizedBox(width: 4),
                    Text('${e.key} ${e.value}', style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── Needs attention ──
  Widget _needsAttentionCard(AdminDashboardStats stats, bool isMobile, {bool compact = false}) {
    final items = compact ? stats.needsAttention.take(3).toList() : stats.needsAttention;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(child: Text('Needs attention', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)))),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Text('Nothing needs attention right now.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1))))
          else
            Column(
              children: List.generate(items.length, (i) {
                final item = items[i];
                final isLast = i == items.length - 1;
                return InkWell(
                  onTap: () => context.go(item.type == 'incident' ? '/incident' : '/service-request'),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: compact ? 6 : 10),
                    decoration: BoxDecoration(border: isLast ? null : const Border(bottom: BorderSide(color: Color(0xFFE5E9F0), width: 0.5))),
                    child: Row(
                      children: [
                        Container(width: 3, height: 32, decoration: BoxDecoration(color: _priorityColor(item.priority), borderRadius: BorderRadius.circular(2))),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)), overflow: TextOverflow.ellipsis, maxLines: 1),
                              Text(item.subtitle, style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B1))),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        _priorityBadge(item.priority),
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

  Color _priorityColor(String priority) {
    switch (priority) {
      case 'high':
        return const Color(0xFFD64545);
      case 'medium':
        return const Color(0xFF854F0B);
      default:
        return const Color(0xFF185FA5);
    }
  }

  Widget _priorityBadge(String priority) {
    final colors = {'high': const Color(0xFFD64545), 'medium': const Color(0xFF854F0B), 'low': const Color(0xFF185FA5)};
    final bg = {'high': const Color(0xFFFDEDED), 'medium': const Color(0xFFFAEEDA), 'low': const Color(0xFFE6F1FB)};
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg[priority] ?? const Color(0xFFF4F7FC), borderRadius: BorderRadius.circular(20)),
      child: Text(priority, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: colors[priority] ?? const Color(0xFF6B7280))),
    );
  }

  Widget _quickAccessCard(IconData icon, String title, String subtitle, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 190,
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
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
                  Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA5B1))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}