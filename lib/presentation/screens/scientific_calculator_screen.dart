import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/calc_button.dart';

class ScientificCalculatorScreen extends ConsumerWidget {
  const ScientificCalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // We can reuse the same provider or use a new one if we wanted separate state.
    // For now, reusing seems appropriate for a seamless experience.
    final state = ref.watch(calculatorProvider);
    final notifier = ref.read(calculatorProvider.notifier);
    final settings = ref.watch(settingsProvider);
    final colorScheme = Theme.of(context).colorScheme;

    void handleTap(VoidCallback action) {
      if (settings.vibrationEnabled) {
        HapticFeedback.lightImpact();
      }
      if (settings.soundEnabled) {
        SystemSound.play(SystemSoundType.click);
      }
      action();
    }

    void onEvaluate() {
      handleTap(
        () => notifier.evaluate(settings.isRadians, settings.precision),
      );
    }

    void onAppend(String val) {
      handleTap(() => notifier.append(val));
    }

    // Force scientific mode visual if needed, but the provider has a flag.
    // Actually, we can just show the buttons directly without checking the flag.

    return Column(
      children: [
        // Display Area
        Expanded(
          flex: 3,
          child: Container(
            padding: const EdgeInsets.all(24),
            alignment: Alignment.bottomRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                AutoSizeText(
                  state.expression,
                  style: TextStyle(
                    fontSize: 32,
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 2,
                  textAlign: TextAlign.end,
                ),
                const Gap(8),
                AutoSizeText(
                  state.result.isEmpty ? '0' : state.result,
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                  maxLines: 1,
                  textAlign: TextAlign.end,
                ),
              ],
            ),
          ),
        ),

        // Settings / Mode Indicators
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              Text(
                settings.isRadians ? 'RAD' : 'DEG',
                style: TextStyle(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => handleTap(notifier.delete),
                icon: const Icon(Icons.backspace_outlined),
              ),
            ],
          ),
        ),
        const Divider(height: 1),

        // Scientific Keypad Area
        Expanded(
          flex: 6,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                // Sci Row 1
                Row(
                  children: [
                    CalcButton(
                      label: 'sin',
                      onTap: () => onAppend('sin('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: 'cos',
                      onTap: () => onAppend('cos('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: 'tan',
                      onTap: () => onAppend('tan('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: 'π',
                      onTap: () => onAppend('π'),
                      isSecondary: true,
                    ),
                  ],
                ),
                // Sci Row 2
                Row(
                  children: [
                    CalcButton(
                      label: 'ln',
                      onTap: () => onAppend('ln('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: 'log',
                      onTap: () => onAppend('log('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: '√',
                      onTap: () => onAppend('sqrt('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: '^',
                      onTap: () => onAppend('^'),
                      isSecondary: true,
                    ),
                  ],
                ),
                // Sci Row 3
                Row(
                  children: [
                    CalcButton(
                      label: '(',
                      onTap: () => onAppend('('),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: ')',
                      onTap: () => onAppend(')'),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: 'e',
                      onTap: () => onAppend('e'),
                      isSecondary: true,
                    ),
                    CalcButton(
                      label: '!',
                      onTap: () => onAppend('!'),
                      isSecondary: true,
                    ),
                  ],
                ),

                // Numpad Row 1
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(
                        label: 'AC',
                        onTap: () => handleTap(notifier.clear),
                        textColor: colorScheme.error,
                      ),
                      CalcButton(label: '%', onTap: () => onAppend('%')),
                      CalcButton(
                        label: '÷',
                        onTap: () => onAppend('÷'),
                        textColor: colorScheme.secondary,
                      ),
                      CalcButton(
                        label: '×',
                        onTap: () => onAppend('×'),
                        textColor: colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                // Numpad Row 2
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(label: '7', onTap: () => onAppend('7')),
                      CalcButton(label: '8', onTap: () => onAppend('8')),
                      CalcButton(label: '9', onTap: () => onAppend('9')),
                      CalcButton(
                        label: '-',
                        onTap: () => onAppend('-'),
                        textColor: colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                // Numpad Row 3
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(label: '4', onTap: () => onAppend('4')),
                      CalcButton(label: '5', onTap: () => onAppend('5')),
                      CalcButton(label: '6', onTap: () => onAppend('6')),
                      CalcButton(
                        label: '+',
                        onTap: () => onAppend('+'),
                        textColor: colorScheme.secondary,
                      ),
                    ],
                  ),
                ),
                // Numpad Row 4
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(label: '1', onTap: () => onAppend('1')),
                      CalcButton(label: '2', onTap: () => onAppend('2')),
                      CalcButton(label: '3', onTap: () => onAppend('3')),
                      // Placeholder or useful key? Maybe 'INV' or something?
                      // Let's use 'abs'? or just spacer?
                      // We can put '00' or something?
                      // Let's just put a generic empty or repeated key if needed, or maybe 'deg/rad' toggle?
                      // Actually, 'deg/rad' is in settings, but useful here.
                      // Let's add a button to toggle settings.isRadians?
                      // `settings` provider might not have a toggle method exposed directly as a usecase.
                      // Let's just put 'ANS' if we had it, or just a placeholder.
                      // CalculatorScreen used '(', ')'.
                      // I moved ( ) to top sci rows.
                      // Let's put '1/x'? -> '^(-1)'
                      CalcButton(
                        label: 'inv',
                        onTap: () => onAppend('^(-1)'),
                        isSecondary: true,
                      ),
                    ],
                  ),
                ),
                // Numpad Row 5
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(
                        label: '0',
                        onTap: () => onAppend('0'),
                      ), // flex 1?
                      CalcButton(label: '.', onTap: () => onAppend('.')),
                      // Another placeholder?
                      // 'sqr'? -> '^2'
                      CalcButton(
                        label: 'sqr',
                        onTap: () => onAppend('^2'),
                        isSecondary: true,
                      ),
                      CalcButton(
                        label: '=',
                        onTap: onEvaluate,
                        backgroundColor: colorScheme.primary,
                        textColor: colorScheme.onPrimary,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
