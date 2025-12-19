import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class UnitConverterScreen extends StatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  State<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends State<UnitConverterScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _inputController = TextEditingController();
  double _result = 0.0;
  String _selectedFromUnit = 'cm';
  String _selectedToUnit = 'm';

  final Map<String, List<String>> _units = {
    'Length': ['cm', 'm', 'km', 'inch', 'feet'],
    'Mass': ['g', 'kg', 'ton', 'lb', 'oz'],
  };

  final Map<String, double> _lengthFactors = {
    'cm': 0.01,
    'm': 1.0,
    'km': 1000.0,
    'inch': 0.0254,
    'feet': 0.3048,
  };

  final Map<String, double> _massFactors = {
    'g': 0.001,
    'kg': 1.0,
    'ton': 1000.0,
    'lb': 0.453592,
    'oz': 0.0283495,
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedFromUnit = _units.values.toList()[_tabController.index][0];
        _selectedToUnit = _units.values.toList()[_tabController.index][1];
        _convert();
      });
    });
  }

  void _convert() {
    if (_inputController.text.isEmpty) {
      setState(() => _result = 0.0);
      return;
    }

    double? inputVal = double.tryParse(_inputController.text);
    if (inputVal == null) return;

    Map<String, double> factors = _tabController.index == 0
        ? _lengthFactors
        : _massFactors;

    double baseValue = inputVal * factors[_selectedFromUnit]!;
    setState(() {
      _result = baseValue / factors[_selectedToUnit]!;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          color: colorScheme.surface,
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Length', icon: Icon(Icons.straighten)),
              Tab(text: 'Mass', icon: Icon(Icons.monitor_weight_outlined)),
            ],
            indicatorColor: colorScheme.primary,
            labelColor: colorScheme.primary,
            unselectedLabelColor: colorScheme.outline,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            _buildInputSection(context),
            const Gap(32),
            const Icon(Icons.arrow_downward, size: 32, color: Colors.grey),
            const Gap(32),
            _buildOutputSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context) {
    final theme = Theme.of(context);
    List<String> currentUnits = _units.values.toList()[_tabController.index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text('From', style: TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedFromUnit,
                items: currentUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedFromUnit = val!;
                    _convert();
                  });
                },
                underline: const SizedBox(),
              ),
            ],
          ),
          const Gap(16),
          TextField(
            controller: _inputController,
            keyboardType: TextInputType.number,
            onChanged: (val) => _convert(),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
            decoration: const InputDecoration(
              hintText: '0.00',
              border: InputBorder.none,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOutputSection(BuildContext context) {
    final theme = Theme.of(context);
    List<String> currentUnits = _units.values.toList()[_tabController.index];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Text(
                'To',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              DropdownButton<String>(
                value: _selectedToUnit,
                dropdownColor: theme.colorScheme.primary,
                style: const TextStyle(color: Colors.white),
                iconEnabledColor: Colors.white,
                items: currentUnits.map((String unit) {
                  return DropdownMenuItem<String>(
                    value: unit,
                    child: Text(unit),
                  );
                }).toList(),
                onChanged: (val) {
                  setState(() {
                    _selectedToUnit = val!;
                    _convert();
                  });
                },
                underline: const SizedBox(),
              ),
            ],
          ),
          const Gap(16),
          Text(
            _result
                .toStringAsFixed(_result < 0.0001 ? 8 : 4)
                .replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), ''),
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
