import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/app_drawer.dart';
import '../providers/calculator_provider.dart';
import 'calculator_screen.dart';
import 'scientific_calculator_screen.dart';
import 'emi_calculator_screen.dart';
import 'history_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
import 'about_screen.dart';
import 'dashboard_screen.dart';
import 'currency_converter_screen.dart';
import 'unit_converter_screen.dart';
import 'date_calculator_screen.dart';
import 'base_converter_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  late final List<Widget> _screens = [
    DashboardScreen(onNavigate: _onDestinationSelected),
    const CalculatorScreen(),
    const ScientificCalculatorScreen(),
    const EmiCalculatorScreen(),
    const CurrencyConverterScreen(),
    const UnitConverterScreen(),
    const DateCalculatorScreen(),
    const BaseConverterScreen(),
    HistoryScreen(onNavigate: _onDestinationSelected),
    const ProfileScreen(),
    const SettingsScreen(),
    const AboutScreen(),
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForIndex(_currentIndex)),
        actions: _getActionsForIndex(_currentIndex),
      ),
      body: _screens[_currentIndex],
      drawer: AppDrawer(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }

  String _getTitleForIndex(int index) {
    switch (index) {
      case 0:
        return 'Dashboard';
      case 1:
        return 'Standard Calculator';
      case 2:
        return 'Scientific Panel';
      case 3:
        return 'EMI & Loan';
      case 4:
        return 'Currency Converter';
      case 5:
        return 'Unit Converter';
      case 6:
        return 'Date & Age';
      case 7:
        return 'Base Converter';
      case 8:
        return 'History';
      case 9:
        return 'Profile';
      case 10:
        return 'Settings';
      case 11:
        return 'About App';
      default:
        return 'CalcLab';
    }
  }

  List<Widget>? _getActionsForIndex(int index) {
    // History Index is 8 now
    if (index == 8) {
      return [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () async {
            // Confirm dialog
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Clear History?'),
                content: const Text('This cannot be undone.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Clear'),
                  ),
                ],
              ),
            );

            if (confirm == true) {
              await ref.read(calculatorProvider.notifier).clearHistory();
            }
          },
        ),
      ];
    }
    return null;
  }
}
