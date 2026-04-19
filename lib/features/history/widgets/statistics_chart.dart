import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/history_provider.dart';

class StatisticsChart extends ConsumerWidget {
  const StatisticsChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyList = ref.watch(historyProvider);

    // If there is no history, don't show the chart
    if (historyList.isEmpty) {
      return const SizedBox.shrink(); 
    }

    // Calculate total risks across all documents to find an average
    int totalRisks = 0;
    for (var item in historyList) {
      totalRisks += item.risks.length;
    }
    double averageRisk = totalRisks / historyList.length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Aperçu de vos analyses',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(context, 'Contrats', historyList.length.toString(), Icons.description),
                _buildStatItem(
                  context, 
                  'Risque Moyen', 
                  averageRisk.toStringAsFixed(1), 
                  Icons.warning_amber_rounded,
                  color: averageRisk > 3 ? Colors.red : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 24),
            // A simple Bar Chart showing the number of risks per recent document
            SizedBox(
              height: 150,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), // Hide bottom text for clean UI
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: false),
                  barGroups: List.generate(
                    // Show up to 5 most recent documents
                    historyList.length > 5 ? 5 : historyList.length,
                    (index) => BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: historyList[index].risks.length.toDouble(),
                          color: Theme.of(context).colorScheme.primary,
                          width: 16,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ).reversed.toList(), // Reverse so newest is on the right
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Center(
              child: Text(
                'Risques détectés (5 derniers docs)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon, {Color? color}) {
    return Column(
      children: [
        Icon(icon, color: color ?? Theme.of(context).colorScheme.primary, size: 32),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}