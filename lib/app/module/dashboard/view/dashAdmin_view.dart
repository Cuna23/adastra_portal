import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../model/dash_model.dart';
import '../view model/dash_vm.dart';
import '../../login/view model/login_vm.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:go_router/go_router.dart';

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
          const Text('Here is what is happening across the portal today.',
              style: TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
          const SizedBox(height: 20),

          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _metricCard('Open incidents', stats.openIncidents, isMobile),
              _metricCard('Pending requests', stats.pendingRequests, isMobile),
              _metricCard('Total assets', stats.totalAssets, isMobile),
              _metricCard('Active staff', stats.activeStaff, isMobile),
            ],
          ),
          const SizedBox(height: 20),

          isNarrow
              ? Column(
                  children: [
                    _incidentsChartCard(stats, isMobile),
                    const SizedBox(height: 16),
                    _needsAttentionCard(stats, isMobile),
                  ],
                )
              : IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 6, child: _incidentsChartCard(stats, isMobile)),
                      const SizedBox(width: 16),
                      Expanded(flex: 5, child: _needsAttentionCard(stats, isMobile)),
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

  Widget _metricCard(String label, int value, bool isMobile) {
    return Container(
      width: isMobile ? double.infinity : 160,
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

  Widget _incidentsChartCard(AdminDashboardStats stats, bool isMobile) {
    final entries = stats.incidentsByStatus.entries.toList();
    final colors = {
      'Open': const Color(0xFFEB6834),
      'In progress': const Color(0xFFEDA100),
      'Resolved': const Color(0xFF008300),
    };
    final maxCount = entries.fold<int>(0, (m, e) => e.value > m ? e.value : m);
    final chartMax = (maxCount == 0 ? 5 : (maxCount * 1.2)).toDouble();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Incidents by status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
          const SizedBox(height: 6),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            children: entries.map((e) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, color: colors[e.key] ?? const Color(0xFF185FA5)),
                  const SizedBox(width: 4),
                  Text('${e.key} ${e.value}', style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                ],
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: chartMax,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: (chartMax / 5).clamp(1, double.infinity),
                      getTitlesWidget: (v, _) => Text(v.toInt().toString(), style: const TextStyle(fontSize: 10, color: Color(0xFF9AA5B1))),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final i = v.toInt();
                        if (i < 0 || i >= entries.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(entries[i].key, style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280))),
                        );
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                gridData: FlGridData(
                  drawVerticalLine: false,
                  horizontalInterval: (chartMax / 5).clamp(1, double.infinity),
                  getDrawingHorizontalLine: (_) => const FlLine(color: Color(0xFFE5E9F0), strokeWidth: 1),
                ),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(entries.length, (i) {
                  final e = entries[i];
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: e.value.toDouble(),
                        color: colors[e.key] ?? const Color(0xFF185FA5),
                        width: 32,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _needsAttentionCard(AdminDashboardStats stats, bool isMobile) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE5E9F0))),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Needs attention', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28))),
          const SizedBox(height: 12),
          if (stats.needsAttention.isEmpty)
            const Text('Nothing needs attention right now.', style: TextStyle(fontSize: 12, color: Color(0xFF9AA5B1)))
          else
            ...stats.needsAttention.map((item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF1B1E28)), overflow: TextOverflow.ellipsis),
                            Text(item.subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF9AA5B1))),
                          ],
                        ),
                      ),
                      _priorityBadge(item.priority),
                    ],
                  ),
                )),
        ],
      ),
    );
  }

  Widget _priorityBadge(String priority) {
    final colors = {
      'high': const Color(0xFFD64545),
      'medium': const Color(0xFF854F0B),
      'low': const Color(0xFF185FA5),
    };
    final bg = {
      'high': const Color(0xFFFDEDED),
      'medium': const Color(0xFFFAEEDA),
      'low': const Color(0xFFE6F1FB),
    };
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
        decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE5E9F0)), borderRadius: BorderRadius.circular(10)),
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