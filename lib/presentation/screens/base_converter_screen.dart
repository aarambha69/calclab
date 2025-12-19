import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BaseConverterScreen extends StatefulWidget {
  const BaseConverterScreen({super.key});

  @override
  State<BaseConverterScreen> createState() => _BaseConverterScreenState();
}

class _BaseConverterScreenState extends State<BaseConverterScreen> {
  final TextEditingController _decimalController = TextEditingController();
  final TextEditingController _binaryController = TextEditingController();
  final TextEditingController _octalController = TextEditingController();
  final TextEditingController _hexController = TextEditingController();

  void _updateFromDecimal(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    try {
      int? decimal = int.tryParse(value);
      if (decimal != null) {
        _binaryController.text = decimal.toRadixString(2);
        _octalController.text = decimal.toRadixString(8);
        _hexController.text = decimal.toRadixString(16).toUpperCase();
      }
    } catch (e) {
      // Handle error
    }
  }

  void _updateFromBinary(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    int? decimal = int.tryParse(value, radix: 2);
    if (decimal != null) {
      _decimalController.text = decimal.toString();
      _octalController.text = decimal.toRadixString(8);
      _hexController.text = decimal.toRadixString(16).toUpperCase();
    }
  }

  void _updateFromOctal(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    int? decimal = int.tryParse(value, radix: 8);
    if (decimal != null) {
      _decimalController.text = decimal.toString();
      _binaryController.text = decimal.toRadixString(2);
      _hexController.text = decimal.toRadixString(16).toUpperCase();
    }
  }

  void _updateFromHex(String value) {
    if (value.isEmpty) {
      _clearAll();
      return;
    }
    int? decimal = int.tryParse(value, radix: 16);
    if (decimal != null) {
      _decimalController.text = decimal.toString();
      _binaryController.text = decimal.toRadixString(2);
      _octalController.text = decimal.toRadixString(8);
    }
  }

  void _clearAll() {
    _decimalController.clear();
    _binaryController.clear();
    _octalController.clear();
    _hexController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(context),
            const Gap(24),
            _buildBaseInput(
              context,
              'Decimal',
              'Base 10',
              _decimalController,
              TextInputType.number,
              _updateFromDecimal,
            ),
            const Gap(16),
            _buildBaseInput(
              context,
              'Binary',
              'Base 2',
              _binaryController,
              TextInputType.number,
              _updateFromBinary,
            ),
            const Gap(16),
            _buildBaseInput(
              context,
              'Octal',
              'Base 8',
              _octalController,
              TextInputType.number,
              _updateFromOctal,
            ),
            const Gap(16),
            _buildBaseInput(
              context,
              'Hexadecimal',
              'Base 16',
              _hexController,
              TextInputType.text,
              _updateFromHex,
            ),
            const Gap(32),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _clearAll,
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            theme.colorScheme.primaryContainer,
            theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(Icons.numbers, size: 48, color: theme.colorScheme.primary),
          const Gap(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Number Base System',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Convert instantly between different number systems.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBaseInput(
    BuildContext context,
    String label,
    String subtitle,
    TextEditingController controller,
    TextInputType keyboardType,
    Function(String) onChanged,
  ) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              subtitle,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.outline,
              ),
            ),
          ],
        ),
        const Gap(8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          onChanged: onChanged,
          decoration: InputDecoration(
            filled: true,
            fillColor: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.3,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon: IconButton(
              icon: const Icon(Icons.copy, size: 20),
              onPressed: () {
                // Simplified copy to clipboard logic for brief
              },
            ),
          ),
          style: theme.textTheme.bodyLarge?.copyWith(
            fontFamily: 'monospace',
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}
