import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

class DateCalculatorScreen extends StatefulWidget {
  const DateCalculatorScreen({super.key});

  @override
  State<DateCalculatorScreen> createState() => _DateCalculatorScreenState();
}

class _DateCalculatorScreenState extends State<DateCalculatorScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime _birthDate = DateTime.now().subtract(const Duration(days: 365 * 25));
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 30));

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _selectDate(
    BuildContext context,
    DateTime initial,
    Function(DateTime) onSelected,
  ) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        onSelected(picked);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Age', icon: Icon(Icons.person_search)),
              Tab(text: 'Difference', icon: Icon(Icons.date_range)),
            ],
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.outline,
          ),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [_buildAgeCalculator(context), _buildDateDifference(context)],
      ),
    );
  }

  Widget _buildAgeCalculator(BuildContext context) {
    final now = DateTime.now();
    final years =
        now.year -
        _birthDate.year -
        ((now.month < _birthDate.month ||
                (now.month == _birthDate.month && now.day < _birthDate.day))
            ? 1
            : 0);

    // Simple month approx
    final months =
        (now.month - _birthDate.month + (now.day < _birthDate.day ? -1 : 0)) %
        12;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildDateSelector(
            context,
            'Date of Birth',
            _birthDate,
            () => _selectDate(context, _birthDate, (date) => _birthDate = date),
          ),
          const Gap(32),
          _buildResultCard(
            context,
            'Your Age',
            '$years Years, $months Months',
            'Next birthday in ${_getDaysToNextBirthday()} days',
          ),
        ],
      ),
    );
  }

  int _getDaysToNextBirthday() {
    final now = DateTime.now();
    var nextBday = DateTime(now.year, _birthDate.month, _birthDate.day);
    if (nextBday.isBefore(now)) {
      nextBday = DateTime(now.year + 1, _birthDate.month, _birthDate.day);
    }
    return nextBday.difference(now).inDays;
  }

  Widget _buildDateDifference(BuildContext context) {
    final diff = _endDate.difference(_startDate).inDays.abs();

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          _buildDateSelector(
            context,
            'Start Date',
            _startDate,
            () => _selectDate(context, _startDate, (date) => _startDate = date),
          ),
          const Gap(16),
          _buildDateSelector(
            context,
            'End Date',
            _endDate,
            () => _selectDate(context, _endDate, (date) => _endDate = date),
          ),
          const Gap(32),
          _buildResultCard(
            context,
            'Difference',
            '$diff Days',
            '${(diff / 7).floor()} Weeks and ${diff % 7} Days',
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelector(
    BuildContext context,
    String label,
    DateTime date,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.labelMedium),
                const Gap(4),
                Text(
                  DateFormat('MMM dd, yyyy').format(date),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Spacer(),
            Icon(Icons.calendar_today, color: theme.colorScheme.primary),
          ],
        ),
      ),
    );
  }

  Widget _buildResultCard(
    BuildContext context,
    String title,
    String result,
    String subtitle,
  ) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Text(title, style: theme.textTheme.titleSmall),
          const Gap(8),
          Text(
            result,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const Gap(8),
          Text(subtitle, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
