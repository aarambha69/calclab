import 'package:flutter/material.dart';

class CalcButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final int flex;
  final bool isSecondary;

  const CalcButton({
    super.key,
    required this.label,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.flex = 1,
    this.isSecondary = false,
  });

  @override
  Widget build(BuildContext context) {
    // Basic Material 3 button styling
    final colorScheme = Theme.of(context).colorScheme;
    final defaultBg = isSecondary ? colorScheme.secondaryContainer : colorScheme.surfaceContainerHighest;
    final defaultFg = isSecondary ? colorScheme.onSecondaryContainer : colorScheme.onSurfaceVariant;

    return Expanded(
      flex: flex,
      child: Padding(
        padding: const EdgeInsets.all(6.0),
        child: Material(
          color: backgroundColor ?? defaultBg,
          borderRadius: BorderRadius.circular(24),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  color: textColor ?? defaultFg,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
