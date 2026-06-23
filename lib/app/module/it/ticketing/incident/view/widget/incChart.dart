import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../view model/incident_vm.dart';

class IncChartsSection extends StatefulWidget {
  final String token;

  const IncChartsSection({super.key, required this.token});

  @override
  State<IncChartsSection> createState() => _IncChartsSectionState();
}

class _IncChartsSectionState extends State<IncChartsSection> {
  static const _borderColor = Color(0xFFE5E7EB);
  static const _textPrimary = Color(0xFF1B1E28);
  static const _textMuted   = Color(0xFF9CA3AF);
  static const _brandBlue   = Color(0xFF185FA5);

  String _mode = 'days';   // 'days' or 'months'

  final Map<String, String> _filterLabels = const {
    'days':   'By Days',
    'months': 'By Months',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchChartStats(widget.token, mode: _mode);
    });
  }

  void _onFilterChanged(String? mode) {
    if (mode == null) return;
    setState(() => _mode = mode);
    context.read<IncidentVM>().fetchChartStats(widget.token, mode: mode);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final barCard = _buildCard(
          title: 'Tickets Overview',
          filter: _buildFilterDropdown(),
          child: _buildBarChart(),
        );

        final pieCard = _buildCard(
          title: 'Tickets by Department',
          child: _buildPiePlaceholder(),
        );

        if (isMobile) {
          return Column(
            children: [
              barCard,
              const SizedBox(height: 16),
              pieCard,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 6, child: barCard),
            const SizedBox(width: 16),
            Expanded(flex: 4, child: pieCard),
          ],
        );
      },
    );
  }

  // ── Card wrapper — title row + optional filter on the right ───────────
  Widget _buildCard({required String title, required Widget child, Widget? filter}) {
    return Container(
      height: 300,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bar_chart_rounded, size: 18, color: _brandBlue),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
              ),
              if (filter != null) filter,
            ],
          ),
          const SizedBox(height: 4),
          const Divider(height: 1, thickness: 1, color: _borderColor),
          const SizedBox(height: 12),
          Expanded(child: child),
        ],
      ),
    );
  }

  // ── Filter dropdown ───────────────────────────────────
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _mode,
          isDense: true,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          icon: const Icon(Icons.keyboard_arrow_down, size: 15, color: _textMuted),
          style: const TextStyle(fontSize: 12, color: _textPrimary, fontWeight: FontWeight.w500),
          items: _filterLabels.entries
              .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
              .toList(),
          onChanged: _onFilterChanged,
        ),
      ),
    );
  }

  Widget _buildBarChart() {
    return Consumer<IncidentVM>(
      builder: (context, vm, _) {
        if (vm.isLoadingStats) {
          return const Center(child: CircularProgressIndicator());
        }

        final stats = vm.weeklyStats;
        if (stats.isEmpty) {
          return const Center(
            child: Text('No data', style: TextStyle(color: _textMuted, fontSize: 13)),
          );
        }

        final maxCount = stats.map((s) => s.count).fold<int>(0, (a, b) => a > b ? a : b);
        final maxY = ((maxCount / 5).ceil() * 5).clamp(5, double.infinity).toDouble();

        final barWidth = _mode == 'days' ? 22.0 : 16.0;   // 7 bars vs 12 bars

        return BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
            barTouchData: BarTouchData(
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (_) => const Color(0xFF1B1E28),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  return BarTooltipItem(
                    '${rod.toY.toInt()}',
                    const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
                  );
                },
              ),
              touchCallback: (event, response) {
                if (!event.isInterestedForInteractions || response == null || response.spot == null) {
                  return;
                }
                final index = response.spot!.touchedBarGroupIndex;
                if (index < 0 || index >= stats.length) return;

                final clickedDate = stats[index].date;
                final vm = context.read<IncidentVM>();
                if (vm.filterDate == clickedDate) {
                  vm.setDateFilter(null);
                } else {
                  vm.setDateFilter(clickedDate);
                }
              },
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: maxY / 5,
              getDrawingHorizontalLine: (_) =>
                  FlLine(color: _borderColor, strokeWidth: 1),
            ),
            borderData: FlBorderData(show: false),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: maxY / 5,
                  getTitlesWidget: (value, _) => Text(
                    value.toInt().toString(),
                    style: const TextStyle(fontSize: 11, color: _textMuted),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) {
                    final i = value.toInt();
                    if (i < 0 || i >= stats.length) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        stats[i].label,
                        style: const TextStyle(fontSize: 10, color: _textMuted),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(stats.length, (i) {
              final isSelected = context.watch<IncidentVM>().filterDate == stats[i].date;
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: stats[i].count.toDouble(),
                    width: barWidth,
                    borderRadius: BorderRadius.circular(4),
                    gradient: LinearGradient(
                      colors: isSelected
                          ? [const Color(0xFF185FA5), const Color(0xFF4A8FD4)]
                          : [const Color(0xFFFF8A3D), const Color(0xFFFFB36B)],
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildPiePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FB),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _borderColor, style: BorderStyle.solid),
      ),
      alignment: Alignment.center,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.pie_chart_outline, size: 32, color: _textMuted),
          SizedBox(height: 8),
          Text('Department breakdown — coming soon',
              style: TextStyle(fontSize: 12, color: _textMuted)),
        ],
      ),
    );
  }
}