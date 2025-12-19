import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'data/local/hive_service.dart';
import 'presentation/providers/settings_provider.dart';
import 'presentation/screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  runApp(const ProviderScope(child: CalcLabApp()));
}

class CalcLabApp extends ConsumerWidget {
  const CalcLabApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'CalcLab',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(settings.seedColor),
      darkTheme: AppTheme.darkTheme(settings.seedColor),
      themeMode: settings.themeMode,
      home: const SplashScreen(),
    );
  }
}
