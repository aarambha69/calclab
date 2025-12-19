import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/user_provider.dart';

class AppDrawer extends ConsumerWidget {
  final Function(int) onDestinationSelected;
  final int selectedIndex;

  const AppDrawer({
    super.key,
    required this.onDestinationSelected,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);
    return NavigationDrawer(
      onDestinationSelected: (index) {
        // Close the drawer before navigating
        Navigator.of(context).pop();
        onDestinationSelected(index);
      },
      selectedIndex: selectedIndex,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Image.asset('assets/images/logo.png', height: 40),
                  const Gap(12),
                  const Text(
                    'CalcLab',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const Gap(24),
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: user.imagePath != null
                        ? FileImage(File(user.imagePath!))
                        : const AssetImage('assets/images/profile_pic.png')
                              as ImageProvider,
                    child: user.imagePath == null
                        ? const Icon(Icons.person, size: 24)
                        : null,
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        Text(
                          'v1.0.0',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const Divider(),
        const NavigationDrawerDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard),
          label: Text('Dashboard'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.calculate_outlined),
          selectedIcon: Icon(Icons.calculate),
          label: Text('Standard Calculator'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.science_outlined),
          selectedIcon: Icon(Icons.science),
          label: Text('Scientific'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.percent_outlined),
          selectedIcon: Icon(Icons.percent),
          label: Text('EMI & Interest'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.currency_exchange_outlined),
          selectedIcon: Icon(Icons.currency_exchange),
          label: Text('Currency Converter'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.straighten_outlined),
          selectedIcon: Icon(Icons.straighten),
          label: Text('Unit Converter'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.calendar_today_outlined),
          selectedIcon: Icon(Icons.calendar_today),
          label: Text('Date & Age'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.numbers_outlined),
          selectedIcon: Icon(Icons.numbers),
          label: Text('Base Converter'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.history_outlined),
          selectedIcon: Icon(Icons.history),
          label: Text('History'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.person_outline),
          selectedIcon: Icon(Icons.person),
          label: Text('Profile'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.settings_outlined),
          selectedIcon: Icon(Icons.settings),
          label: Text('Settings'),
        ),
        const Divider(),
        const NavigationDrawerDestination(
          icon: Icon(Icons.info_outline),
          selectedIcon: Icon(Icons.info),
          label: Text('About App'),
        ),
      ],
    );
  }
}
