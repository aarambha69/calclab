import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../widgets/recent_calculations_widget.dart';
import '../providers/user_provider.dart';
import '../providers/emi_provider.dart';
import 'saved_emi_plans_screen.dart';
import '../../data/models/emi_plan.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigate;

  const DashboardScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final user = ref.watch(userProvider);
    final savedPlans = ref.watch(emiPlansProvider);

    // Quick Stats or Greeting could go here
    // For now we assume static greeting or utilize UserProvider if available

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome back,',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.secondary,
            ),
          ),
          Text(
            user.name,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(24),

          // Tools Grid
          Text(
            'Tools',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Gap(16),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 1.5,
            children: [
              _buildToolCard(
                context,
                'Calculator',
                Icons.calculate,
                colorScheme.primaryContainer,
                () => onNavigate(
                  1,
                ), // Index 1 is Standard Calc (assuming 0 is Dashboard)
              ),
              _buildToolCard(
                context,
                'Scientific',
                Icons.science,
                colorScheme.secondaryContainer,
                () => onNavigate(2),
              ),
              _buildToolCard(
                context,
                'EMI & Loan',
                Icons.account_balance,
                colorScheme.tertiaryContainer,
                () => onNavigate(3),
              ),
              _buildToolCard(
                context,
                'Saved Plans${savedPlans.isNotEmpty ? " (${savedPlans.length})" : ""}',
                Icons.folder_special,
                colorScheme.surfaceContainerHighest,
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SavedEmiPlansScreen(),
                    ),
                  ).then((selected) {
                    if (selected is EmiPlan) {
                      ref.read(selectedEmiPlanProvider.notifier).state =
                          selected;
                      onNavigate(3);
                    }
                  });
                },
              ),
              _buildToolCard(
                context,
                'Currency',
                Icons.currency_exchange,
                colorScheme.primaryContainer.withValues(alpha: 0.7),
                () => onNavigate(4),
              ),
              _buildToolCard(
                context,
                'Unit Converter',
                Icons.straighten,
                colorScheme.secondaryContainer.withValues(alpha: 0.7),
                () => onNavigate(5),
              ),
              _buildToolCard(
                context,
                'Date & Age',
                Icons.calendar_today,
                colorScheme.tertiaryContainer.withValues(alpha: 0.7),
                () => onNavigate(6),
              ),
              _buildToolCard(
                context,
                'Base Converter',
                Icons.numbers,
                colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
                () => onNavigate(7),
              ),
            ],
          ),

          const Gap(24),

          if (savedPlans.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Saved EMI Plans',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SavedEmiPlansScreen(),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const Gap(12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: savedPlans.length > 5 ? 5 : savedPlans.length,
                itemBuilder: (context, index) {
                  final plan = savedPlans[index];
                  return Container(
                    width: 160,
                    margin: const EdgeInsets.only(right: 12),
                    child: Card(
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: colorScheme.outlineVariant,
                          width: 1,
                        ),
                      ),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          ref.read(selectedEmiPlanProvider.notifier).state =
                              plan;
                          onNavigate(3);
                        },
                        child: Stack(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    plan.name,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const Gap(4),
                                  Text(
                                    'NPR ${plan.amount.toStringAsFixed(0)} @ ${plan.rate}%',
                                    style: theme.textTheme.bodySmall,
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton(
                                icon: const Icon(Icons.close, size: 16),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                splashRadius: 16,
                                onPressed: () {
                                  ref
                                      .read(emiPlansProvider.notifier)
                                      .deletePlan(plan.id);
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            const Gap(24),
          ],

          RecentCalculationsWidget(onNavigate: onNavigate),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return Card(
      elevation: 0,
      color: color,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(
                icon,
                size: 32,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
