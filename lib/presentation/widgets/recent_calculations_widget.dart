import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/calculator_provider.dart';

class RecentCalculationsWidget extends ConsumerWidget {
  final Function(int)? onNavigate;

  const RecentCalculationsWidget({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final history = state.history.take(5).toList();
    final colorScheme = Theme.of(context).colorScheme;

    if (history.isEmpty) {
      return Card(
        color: colorScheme.surfaceContainer,
        child: const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: Text('No recent calculations')),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainer,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    if (onNavigate != null) {
                      onNavigate!(8); // History index is 8
                    }
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: history.length,
            separatorBuilder: (_, index) =>
                const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                visualDensity: VisualDensity.compact,
                title: Text(
                  item.result,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(item.expression),
                trailing: Text(
                  DateFormat.Hm().format(item.timestamp),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onTap: () {
                  // Load back into calculator
                  ref.read(calculatorProvider.notifier).loadHistoryItem(item);
                  if (onNavigate != null) {
                    onNavigate!(1); // Standard Calculator
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
