import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:legal_ease_ai/core/extensions/l10n_extension.dart';
import 'package:legal_ease_ai/widgets/widgets.dart';
import '../providers/history_provider.dart';

class StatisticsChart extends StatelessWidget {
  const StatisticsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final l10n = context.l10n;
        final historyAsync = ref.watch(historyProvider);

        return historyAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (_, __) => const SizedBox.shrink(),
          data: (historyList) {
            if (historyList.isEmpty) return const SizedBox.shrink();

            return CustomCard(
              title: l10n.statisticsOverview,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InfoCard(
                    icon: Icons.description,
                    label: l10n.contractsCount,
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
