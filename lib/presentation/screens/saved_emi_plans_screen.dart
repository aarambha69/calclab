import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:gap/gap.dart';
import '../providers/emi_provider.dart';
import '../../data/models/emi_plan.dart';

class SavedEmiPlansScreen extends ConsumerWidget {
  const SavedEmiPlansScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plans = ref.watch(emiPlansProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Plans'),
        actions: [
          if (plans.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear All',
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Plans?'),
                    content: const Text(
                      'This will permanently delete ALL saved EMI plans. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          ref.read(emiPlansProvider.notifier).clearAllPlans();
                          Navigator.pop(context);
                        },
                        child: Text(
                          'Clear All',
                          style: TextStyle(color: theme.colorScheme.error),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
      body: plans.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.folder_open,
                    size: 64,
                    color: theme.colorScheme.outline,
                  ),
                  const Gap(16),
                  Text('No saved plans yet', style: theme.textTheme.titleLarge),
                ],
              ),
            )
          : ListView.builder(
              itemCount: plans.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final EmiPlan plan = plans[index];
                return Dismissible(
                  key: Key(plan.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: theme.colorScheme.errorContainer,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.delete,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  onDismissed: (_) {
                    ref.read(emiPlansProvider.notifier).deletePlan(plan.id);
                  },
                  child: Card(
                    child: ListTile(
                      title: Text(
                        plan.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        '${DateFormat.yMMMd().format(plan.createdAt)}\n'
                        'Principal: NPR ${plan.amount.toStringAsFixed(0)} | Rate: ${plan.rate}% | Tenure: ${plan.tenure} ${plan.isYearly ? 'Yr' : 'Mo'}',
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        color: theme.colorScheme.error,
                        onPressed: () {
                          // Show confirmation dialog before deleting
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: const Text('Delete Plan?'),
                              content: Text(
                                'Are you sure you want to delete "${plan.name}"?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    ref
                                        .read(emiPlansProvider.notifier)
                                        .deletePlan(plan.id);
                                    Navigator.pop(context);
                                  },
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(
                                      color: theme.colorScheme.error,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      onTap: () {
                        Navigator.pop(context, plan);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }
}
