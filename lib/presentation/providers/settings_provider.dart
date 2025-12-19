import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive_service.dart';

// State class for Settings
class SettingsState {
  final ThemeMode themeMode;
  final Color seedColor;
  final int precision;
  final bool isRadians;
  final bool vibrationEnabled;
  final bool soundEnabled;

  SettingsState({
    this.themeMode = ThemeMode.system,
    this.seedColor = Colors.deepPurple,
    this.precision = 2,
    this.isRadians = false,
    this.vibrationEnabled = true,
    this.soundEnabled = false,
  });

  SettingsState copyWith({
    ThemeMode? themeMode,
    Color? seedColor,
    int? precision,
    bool? isRadians,
    bool? vibrationEnabled,
    bool? soundEnabled,
  }) {
    return SettingsState(
      themeMode: themeMode ?? this.themeMode,
      seedColor: seedColor ?? this.seedColor,
      precision: precision ?? this.precision,
      isRadians: isRadians ?? this.isRadians,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(SettingsState()) {
    _loadSettings();
  }

  void _loadSettings() {
    final box = HiveService.settingsBox;
    final themeIndex = box.get(
      'themeMode',
      defaultValue: 0,
    ); // 0: System, 1: Light, 2: Dark
    final colorValue = box.get(
      'seedColor',
      defaultValue: Colors.deepPurple.toARGB32(),
    );
    final precision = box.get('precision', defaultValue: 2);
    final isRadians = box.get('isRadians', defaultValue: false);
    final vibration = box.get('vibration', defaultValue: true);
    final sound = box.get('sound', defaultValue: false);

    ThemeMode mode;
    if (themeIndex == 1) {
      mode = ThemeMode.light;
    } else if (themeIndex == 2) {
      mode = ThemeMode.dark;
    } else {
      mode = ThemeMode.system;
    }

    state = SettingsState(
      themeMode: mode,
      seedColor: Color(colorValue),
      precision: precision,
      isRadians: isRadians,
      vibrationEnabled: vibration,
      soundEnabled: sound,
    );
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = state.copyWith(themeMode: mode);
    int index = 0;
    if (mode == ThemeMode.light) index = 1;
    if (mode == ThemeMode.dark) index = 2;
    await HiveService.settingsBox.put('themeMode', index);
  }

  Future<void> setSeedColor(Color color) async {
    state = state.copyWith(seedColor: color);
    await HiveService.settingsBox.put('seedColor', color.toARGB32());
  }

  Future<void> setPrecision(int precision) async {
    state = state.copyWith(precision: precision);
    await HiveService.settingsBox.put('precision', precision);
  }

  Future<void> toggleAngleUnit() async {
    final newValue = !state.isRadians;
    state = state.copyWith(isRadians: newValue);
    await HiveService.settingsBox.put('isRadians', newValue);
  }

  Future<void> toggleVibration(bool value) async {
    state = state.copyWith(vibrationEnabled: value);
    await HiveService.settingsBox.put('vibration', value);
  }

  Future<void> toggleSound(bool value) async {
    state = state.copyWith(soundEnabled: value);
    await HiveService.settingsBox.put('sound', value);
  }
}

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>(
  (ref) {
    return SettingsNotifier();
  },
);
