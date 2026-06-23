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

  int _selectedDays = 7;

  final Map<int, String> _filterLabels = const {
    7:  'Last 7 days',
    14: 'Last 14 days',
    30: 'Last 30 days',
    60: 'Last 60 days',
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchWeeklyStats(widget.token, days: _selectedDays);
    });
  }

  void _onFilterChanged(int? days) {
    if (days == null) return;
    setState(() => _selectedDays = days);
    context.read<IncidentVM>().fetchWeeklyStats(widget.token, days: days);
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

  // ── Filter dropdown — 7/14/30/60 days ───────────────────────────────────
  Widget _buildFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _borderColor),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedDays,
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16, color: _textMuted),
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

        // Wider range = thinner bars + fewer label ticks to avoid clutter
        final barWidth = _selectedDays <= 7 ? 22.0 : (_selectedDays <= 14 ? 14.0 : 6.0);
        final labelInterval = _selectedDays <= 14 ? 1 : (_selectedDays <= 30 ? 3 : 7);

        return BarChart(
          BarChartData(
            maxY: maxY,
            alignment: BarChartAlignment.spaceAround,
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
                    if (i % labelInterval != 0) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        stats[i].day,
                        style: const TextStyle(fontSize: 10, color: _textMuted),
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: List.generate(stats.length, (i) {
              return BarChartGroupData(
                x: i,
                barRods: [
                  BarChartRodData(
                    toY: stats[i].count.toDouble(),
                    width: barWidth,
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A3D), Color(0xFFFFB36B)],
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