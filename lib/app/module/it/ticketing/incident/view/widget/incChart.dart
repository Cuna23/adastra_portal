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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidentVM>().fetchWeeklyStats(widget.token);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 700;

        final barCard = _buildCard(
          title: 'Tickets — Last 7 Days',
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

  Widget _buildCard({required String title, required Widget child}) {
    return Container(
      height: 280,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 14, fontWeight: FontWeight.w600, color: _textPrimary)),
          const SizedBox(height: 16),
          Expanded(child: child),
        ],
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
                    return Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        stats[i].day,
                        style: const TextStyle(fontSize: 11, color: _textMuted),
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
                    width: 22,
                    borderRadius: BorderRadius.circular(4),
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF8A3D), Color(0xFFFFB36B)], // warm orange gradient
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

  // Placeholder — pie chart integration later
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