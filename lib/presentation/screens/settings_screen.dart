import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      children: [
        RadioGroup<ThemeMode>(
          groupValue: settings.themeMode,
          onChanged: (val) {
            if (val != null) notifier.setThemeMode(val);
          },
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: const Text('System Theme'),
                value: ThemeMode.system,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Light Theme'),
                value: ThemeMode.light,
              ),
              RadioListTile<ThemeMode>(
                title: const Text('Dark Theme'),
                value: ThemeMode.dark,
              ),
            ],
          ),
        ),
        const Divider(),
        ListTile(
          title: const Text('Accent Color'),
          trailing: CircleAvatar(
            backgroundColor: settings.seedColor,
            radius: 12,
          ),
          onTap: () async {
            // Simple color picker dialog
            await showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Select Color'),
                content: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      [
                            Colors.deepPurple,
                            Colors.blue,
                            Colors.green,
                            Colors.orange,
                            Colors.red,
                            Colors.pink,
                            Colors.teal,
                          ]
                          .map(
                            (c) => InkWell(
                              onTap: () {
                                notifier.setSeedColor(c);
                                Navigator.pop(context);
                              },
                              child: CircleAvatar(backgroundColor: c),
                            ),
                          )
                          .toList(),
                ),
              ),
            );
          },
        ),
        const Divider(),
        ListTile(
          title: const Text('Decimal Precision'),
          trailing: DropdownButton<int>(
            value: settings.precision,
            underline: const SizedBox(),
            items: [0, 1, 2, 3, 4, 5, 6]
                .map(
                  (e) => DropdownMenuItem(value: e, child: Text(e.toString())),
                )
                .toList(),
            onChanged: (val) {
              if (val != null) notifier.setPrecision(val);
            },
          ),
        ),
        SwitchListTile(
          title: const Text('Angle Unit (Radians)'),
          subtitle: Text(settings.isRadians ? 'Radians' : 'Degrees'),
          value: settings.isRadians,
          onChanged: (val) {
            notifier.toggleAngleUnit();
          },
        ),
        SwitchListTile(
          title: const Text('Vibration'),
          value: settings.vibrationEnabled,
          onChanged: (val) {
            notifier.toggleVibration(val);
          },
        ),
        SwitchListTile(
          title: const Text('Sound'),
          value: settings.soundEnabled,
          onChanged: (val) {
            notifier.toggleSound(val);
          },
        ),
      ],
    );
  }
}
