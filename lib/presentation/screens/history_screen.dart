import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../providers/calculator_provider.dart';

class HistoryScreen extends ConsumerWidget {
  final Function(int)? onNavigate;

  const HistoryScreen({super.key, this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(calculatorProvider);
    final history = state.history;

    return history.isEmpty
        ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.history,
                  size: 64,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const Gap(16),
                Text(
                  'No History',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          )
        : ListView.separated(
            itemCount: history.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = history[index];
              return ListTile(
                title: Text(
                  item.result,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.expression),
                    Text(
                      DateFormat.MMMd().add_Hm().format(item.timestamp),
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                trailing: IconButton(
                  icon: Icon(
                    item.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: item.isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    ref
                        .read(calculatorProvider.notifier)
                        .toggleFavorite(item.id);
                  },
                ),
                onTap: () {
                  // Load back into calculator
                  ref.read(calculatorProvider.notifier).loadHistoryItem(item);
                  if (onNavigate != null) {
                    onNavigate!(1); // Index 1 is Standard Calculator
                  }
                },
              );
            },
          );
  }
}
