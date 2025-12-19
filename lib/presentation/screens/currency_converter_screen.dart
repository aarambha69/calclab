import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';
import '../providers/currency_provider.dart';
import '../providers/calculator_provider.dart';

class CurrencyConverterScreen extends ConsumerStatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  ConsumerState<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState
    extends ConsumerState<CurrencyConverterScreen> {
  late TextEditingController _amountController;
  late TextEditingController _manualRateController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(currencyProvider);
    _amountController = TextEditingController(
      text: state.amount == 0 ? '' : state.amount.toString(),
    );
    _manualRateController = TextEditingController(
      text: state.manualRate.toString(),
    );
  }

  @override
  void dispose() {
    _amountController.dispose();
    _manualRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(currencyProvider);
    final notifier = ref.read(currencyProvider.notifier);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Sync controllers if externally changed (like swap)
    if (_amountController.text !=
            (state.amount == 0 ? '' : state.amount.toString()) &&
        !FocusScope.of(context).hasFocus) {
      _amountController.text = state.amount == 0 ? '' : state.amount.toString();
    }
    if (_manualRateController.text != state.manualRate.toString() &&
        !FocusScope.of(context).hasFocus) {
      _manualRateController.text = state.manualRate.toString();
    }

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(theme, notifier, state.isLoading),
              const Gap(32),

              if (state.error != null)
                _buildErrorCard(state.error!, notifier, colorScheme),

              // Main Card
              Card(
                elevation: 8,
                shadowColor: colorScheme.shadow.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        colorScheme.surface,
                        colorScheme.surfaceContainerHighest.withValues(
                          alpha: 0.5,
                        ),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // From Currency Selection
                      _buildCurrencyInput(
                        context,
                        label: 'From',
                        value: state.fromCurrency,
                        onChanged: (val) => notifier.setFromCurrency(val!),
                        onAmountChanged: (val) {
                          final parsed = double.tryParse(val) ?? 0.0;
                          notifier.setAmount(parsed);
                        },
                      ),

                      const Gap(16),

                      // Swap Button
                      Center(
                        child: IconButton.filledTonal(
                          onPressed: notifier.swapCurrencies,
                          icon: const Icon(Icons.swap_vert, size: 28),
                          style: IconButton.styleFrom(
                            padding: const EdgeInsets.all(12),
                          ),
                        ),
                      ),

                      const Gap(16),

                      // To Currency Selection
                      _buildCurrencyDisplay(
                        context,
                        label: 'To',
                        value: state.toCurrency,
                        onChanged: (val) => notifier.setToCurrency(val!),
                        result: state.result,
                      ),
                    ],
                  ),
                ),
              ),

              const Gap(32),

              // Mode Toggle & Manual Input
              _buildModeToggle(context, state, notifier, colorScheme),

              const Gap(24),

              // Rate Indicator
              if (state.currentRate > 0)
                _buildRateIndicator(context, state, colorScheme),

              const Gap(32),

              // Recent Conversions Title
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: Row(
                  children: [
                    Icon(Icons.history, size: 20, color: colorScheme.secondary),
                    const Gap(8),
                    Text(
                      'Recent Conversions',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),

              // History Section (Filtered)
              _buildHistoryList(context, ref, colorScheme),

              const Gap(24),
            ],
          ),
        ),
        if (state.isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.1),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  Widget _buildHeader(
    ThemeData theme,
    CurrencyNotifier notifier,
    bool isLoading,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Currency',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              'Converter',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        IconButton.filledTonal(
          onPressed: isLoading ? null : () => notifier.fetchRates(),
          icon: const Icon(Icons.refresh),
          tooltip: 'Refresh Rates',
        ),
      ],
    );
  }

  Widget _buildErrorCard(
    String error,
    CurrencyNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Card(
      color: colorScheme.errorContainer,
      margin: const EdgeInsets.only(bottom: 24),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Icon(Icons.error_outline, color: colorScheme.error),
                const Gap(12),
                Expanded(
                  child: Text(
                    error,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
            const Gap(12),
            FilledButton.icon(
              onPressed: () => notifier.fetchRates(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: FilledButton.styleFrom(
                backgroundColor: colorScheme.error,
                foregroundColor: colorScheme.onError,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrencyInput(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
    required ValueChanged<String> onAmountChanged,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            _buildCurrencyDropdown(context, value, onChanged),
          ],
        ),
        const Gap(8),
        TextField(
          controller: _amountController,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: theme.colorScheme.surface,
            prefixIcon: const Icon(Icons.edit_note),
            hintText: 'Enter amount',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          ],
          onChanged: onAmountChanged,
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDisplay(
    BuildContext context, {
    required String label,
    required String value,
    required ValueChanged<String?> onChanged,
    required double result,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: theme.textTheme.labelLarge),
            _buildCurrencyDropdown(context, value, onChanged),
          ],
        ),
        const Gap(8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withValues(alpha: 0.2),
            ),
          ),
          width: double.infinity,
          child: Text(
            result.toStringAsFixed(2),
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCurrencyDropdown(
    BuildContext context,
    String value,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          onChanged: onChanged,
          items: commonCurrencies.map((c) {
            return DropdownMenuItem(
              value: c,
              child: Text(
                c,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildModeToggle(
    BuildContext context,
    CurrencyState state,
    CurrencyNotifier notifier,
    ColorScheme colorScheme,
  ) {
    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Icon(
                  state.isAutoMode ? Icons.auto_awesome : Icons.edit,
                  color: colorScheme.primary,
                ),
                const Gap(12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isAutoMode
                            ? 'Automatic Rates (NRB)'
                            : 'Manual Rate',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        state.isAutoMode
                            ? 'Using Nepal Rastra Bank data'
                            : 'Define your own exchange rate',
                        style: TextStyle(
                          fontSize: 12,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: state.isAutoMode,
                  onChanged: (val) => notifier.toggleMode(),
                ),
              ],
            ),
            if (!state.isAutoMode) ...[
              const Gap(16),
              TextField(
                controller: _manualRateController,
                decoration: InputDecoration(
                  labelText: 'Exchange Rate',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.currency_exchange),
                  hintText: 'e.g. 1.25',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                ],
                onChanged: (val) {
                  final parsed = double.tryParse(val) ?? 1.0;
                  notifier.setManualRate(parsed);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRateIndicator(
    BuildContext context,
    CurrencyState state,
    ColorScheme colorScheme,
  ) {
    final fromRate = state.cachedRates[state.fromCurrency];
    final toRate = state.cachedRates[state.toCurrency];
    final showDetails = state.isAutoMode && fromRate != null && toRate != null;

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: colorScheme.secondaryContainer.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.secondary.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 18, color: colorScheme.secondary),
              const Gap(8),
              Text(
                '1 ${state.fromCurrency} = ${state.currentRate.toStringAsFixed(4)} ${state.toCurrency}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSecondaryContainer,
                ),
              ),
            ],
          ),
        ),
        if (showDetails) ...[
          const Gap(12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (state.fromCurrency != 'NPR')
                  _buildSubRateInfo(
                    'Mid: ${fromRate.rate.toStringAsFixed(2)} NPR',
                    colorScheme,
                  ),
                if (state.toCurrency != 'NPR')
                  _buildSubRateInfo(
                    'Mid: ${toRate.rate.toStringAsFixed(2)} NPR',
                    colorScheme,
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSubRateInfo(String text, ColorScheme colorScheme) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 11,
        color: colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }

  Widget _buildHistoryList(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    final calcState = ref.watch(calculatorProvider);
    final currencyHistory = calcState.history
        .where((item) => item.expression.contains('➔'))
        .take(5)
        .toList();

    if (currencyHistory.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Text(
            'No recent currency history',
            style: TextStyle(color: colorScheme.outline),
          ),
        ),
      );
    }

    return Card(
      elevation: 0,
      color: colorScheme.secondaryContainer.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: currencyHistory.length,
        separatorBuilder: (_, index) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (context, index) {
          final item = currencyHistory[index];
          return ListTile(
            title: Text(
              item.result,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(item.expression),
            trailing: Text(
              DateFormat.Hm().format(item.timestamp),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          );
        },
      ),
    );
  }
}
