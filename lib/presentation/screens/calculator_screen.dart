import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import '../providers/calculator_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/calc_button.dart';

class CalculatorScreen extends ConsumerWidget {
  const CalculatorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

        // Toolbar (Scientific Toggle)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            children: [
              IconButton(
                onPressed: () => handleTap(notifier.toggleScientific),
                icon: Icon(
                  state.isScientific ? Icons.science : Icons.science_outlined,
                  color: state.isScientific
                      ? colorScheme.primary
                      : colorScheme.onSurface,
                ),
              ),
              if (state.isScientific)
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

        // Keypad Area
        Expanded(
          flex: state.isScientific ? 6 : 4,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                if (state.isScientific) ...[
                  // Scientific Rows
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
                ],
                // Standard Keypad
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
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(label: '1', onTap: () => onAppend('1')),
                      CalcButton(label: '2', onTap: () => onAppend('2')),
                      CalcButton(label: '3', onTap: () => onAppend('3')),
                      CalcButton(
                        label: '(',
                        onTap: () => onAppend('('),
                        isSecondary: true,
                      ), // Placeholder
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      CalcButton(
                        label: '0',
                        onTap: () => onAppend('0'),
                      ), // flex 1, next is .
                      CalcButton(label: '.', onTap: () => onAppend('.')),
                      CalcButton(
                        label: ')',
                        onTap: () => onAppend(')'),
                        isSecondary: true,
                      ), // Placeholder
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
