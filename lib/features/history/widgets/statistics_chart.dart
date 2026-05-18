import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/history_provider.dart';

/// StatisticsChart
///
/// Displays a quick statistics overview for the user's analysis history.
/// Uses [InfoCard] from the shared widget library to avoid duplication.
class StatisticsChart extends StatelessWidget {
  const StatisticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final historyAsync = ref.watch(historyProvider);

        return historyAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (historyList) {
            if (historyList.isEmpty) return const SizedBox.shrink();

            return CustomCard(
              title: 'Aperçu de vos analyses',
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoCard(
                    icon: Icons.description,
                    label: 'Contrats',
                    value: historyList.length.toString(),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}