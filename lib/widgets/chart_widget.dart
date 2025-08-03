import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

/// 通用折线图组件（可用于报警趋势图或婴儿成长趋势图）
class MultiLineChart extends StatelessWidget {
  final Map<String, List<FlSpot>> dataSeries; // 每条线的数据
  final Map<String, Color> colorMap; // 每条线的颜色
  final String title; // 可选标题
  final String xLabelUnit; // 横坐标单位（如小时"h"或月份"M"）
  final double interval; // 横坐标刻度间隔

  const MultiLineChart({
    super.key,
    required this.dataSeries,
    required this.colorMap,
    this.title = '',
    this.xLabelUnit = 'h',
    this.interval = 2,
  });

  @override
  Widget build(BuildContext context) {
    final lines = dataSeries.entries.map((entry) {
      return _buildLine(entry.value, colorMap[entry.key] ?? Colors.blue);
    }).toList();

    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  gridData: FlGridData(show: false),
                  titlesData: FlTitlesData(
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: interval,
                        getTitlesWidget: (value, _) => Text("${value.toInt()}$xLabelUnit", style: const TextStyle(fontSize: 10)),
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: lines,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLine(List<FlSpot> spots, Color color) {
    return LineChartBarData(
      isCurved: true,
      color: color,
      barWidth: 3,
      dotData: FlDotData(
        show: true,
        getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 0,
        ),
      ),
      belowBarData: BarAreaData(
        show: true,
        color: color.withOpacity(0.2),
      ),
      spots: spots,
    );
  }
}

/// 柱状图：每小时报警等级分布
class HourlyBarChart extends StatefulWidget {
  final Map<int, Map<String, int>> hourlyStats;

  const HourlyBarChart({super.key, required this.hourlyStats});

  @override
  State<HourlyBarChart> createState() => _HourlyBarChartState();
}

class _HourlyBarChartState extends State<HourlyBarChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: BarChart(
          BarChartData(
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                tooltipPadding: const EdgeInsets.all(8),
                tooltipMargin: 8,
                tooltipRoundedRadius: 8,
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  String level = ['危险', '警告', '安全'][rodIndex];
                  return BarTooltipItem(
                    '${group.x.toInt()}h\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                    children: [
                      TextSpan(
                        text: '$level: ${rod.toY.toInt()}',
                        style: const TextStyle(color: Colors.redAccent),
                      ),
                    ],
                  );
                },
              ),
              touchCallback: (event, response) {
                setState(() {
                  if (!event.isInterestedForInteractions || response == null || response.spot == null) {
                    touchedIndex = -1;
                  } else {
                    touchedIndex = response.spot!.touchedBarGroupIndex;
                  }
                });
              },
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, _) => Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text("${value.toInt()}h", style: const TextStyle(fontSize: 10)),
                  ),
                  reservedSize: 28,
                ),
              ),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            gridData: const FlGridData(show: false),
            barGroups: _buildBarGroups(),
          ),
        ),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return widget.hourlyStats.entries.map((entry) {
      final hour = entry.key;
      final isTouched = hour == touchedIndex;

      double getY(String level) {
        return (entry.value[level] ?? 0).toDouble() + (isTouched ? 1.0 : 0.0);
      }

      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: getY('danger'),
            width: 16,
            borderRadius: BorderRadius.circular(6),
            color: Colors.redAccent,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 20,
              color: Colors.redAccent.withOpacity(0.1),
            ),
          ),
          BarChartRodData(
            toY: getY('warning'),
            width: 16,
            borderRadius: BorderRadius.circular(6),
            color: Colors.orange,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 20,
              color: Colors.orange.withOpacity(0.1),
            ),
          ),
          BarChartRodData(
            toY: getY('safe'),
            width: 16,
            borderRadius: BorderRadius.circular(6),
            color: Colors.green,
            backDrawRodData: BackgroundBarChartRodData(
              show: true,
              toY: 20,
              color: Colors.green.withOpacity(0.1),
            ),
          ),
        ],
      );
    }).toList();
  }
}
