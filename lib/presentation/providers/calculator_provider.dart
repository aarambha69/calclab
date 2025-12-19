import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:math_expressions/math_expressions.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter/foundation.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/history_item.dart';

class CalculatorState {
  final String expression;
  final String result;
  final bool isScientific;
  final List<HistoryItem> history;

  CalculatorState({
    this.expression = '',
    this.result = '0',
    this.isScientific = false,
    this.history = const [],
  });

  CalculatorState copyWith({
    String? expression,
    String? result,
    bool? isScientific,
    List<HistoryItem>? history,
  }) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
      isScientific: isScientific ?? this.isScientific,
      history: history ?? this.history,
    );
  }
}

class CalculatorNotifier extends StateNotifier<CalculatorState> {
  CalculatorNotifier() : super(CalculatorState()) {
    _loadHistory();
  }

  void _loadHistory() {
    try {
      final box = HiveService.historyBox;
      final List<HistoryItem> safeHistory = [];

      // Manual loop to prevent any cast errors on the list itself or contents
      for (final item in box.values) {
        safeHistory.add(item);
      }

      // Sort by timestamp desc
      safeHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      state = state.copyWith(history: safeHistory);
    } catch (e) {
      debugPrint('History Load Error: $e');
      // Fallback to empty list to keep app running
      state = state.copyWith(history: []);
    }
  }

  Future<void> _saveHistory(HistoryItem item) async {
    final box = HiveService.historyBox;
    await box.put(item.id, item);

    // Reload to ensure sync with robust typing
    final updatedHistory = box.values.whereType<HistoryItem>().toList();
    updatedHistory.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    state = state.copyWith(history: updatedHistory);
  }

  void toggleScientific() {
    state = state.copyWith(isScientific: !state.isScientific);
  }

  void append(String value) {
    if (state.result != '0' && state.expression.isEmpty) {
      // If there was a previous result and we start typing
      if (_isOperator(value)) {
        // If it's an operator (including scientific ones needing operands like ^ or !),
        // we use the previous result as the starting operand.
        state = state.copyWith(expression: state.result + value, result: '0');
        return;
      } else {
        // If it's a number/function that starts a new term, we start fresh.
        state = state.copyWith(expression: value, result: '0');
        return;
      }
    }

    state = state.copyWith(expression: state.expression + value);
  }

  bool _isOperator(String value) {
    // Basic operators
    if ('+-*/%'.contains(value)) return true;
    // Scientific operators that might be appended to a number
    if (value == '^' || value == '!' || value.startsWith('^')) return true;
    return false;
  }

  void clear() {
    state = state.copyWith(expression: '', result: '0');
  }

  void delete() {
    if (state.expression.isNotEmpty) {
      state = state.copyWith(
        expression: state.expression.substring(0, state.expression.length - 1),
      );
    }
  }

  void evaluate(bool isRadians, int precision) {
    try {
      String finalExpression = state.expression;
      if (finalExpression.isEmpty) return;

      // Basic replacements
      finalExpression = finalExpression.replaceAll('×', '*');
      finalExpression = finalExpression.replaceAll('÷', '/');
      finalExpression = finalExpression.replaceAll(
        'π',
        '3.14159265358979323846',
      );
      finalExpression = finalExpression.replaceAll(
        'e',
        '2.71828182845904523536',
      );
      finalExpression = finalExpression.replaceAll('%', '/100');

      // Add missing closing parentheses
      int openParentheses = '('.allMatches(finalExpression).length;
      int closeParentheses = ')'.allMatches(finalExpression).length;
      while (openParentheses > closeParentheses) {
        finalExpression += ')';
        closeParentheses++;
      }

      if (!isRadians) {
        // More robust trigonometry replacement for Degrees
        // We use a regex to find sin/cos/tan( and wrap their contents with a degree-to-radian conversion.
        // math_expressions doesn't have a built-in DEG mode, so we must convert at the expression level.
        // Replace: sin(x) -> sin(x * pi / 180)
        finalExpression = _convertTrigToRadians(finalExpression);
      }

      // Handle log base 10 (math_expressions uses log(base, value))
      // The keypad appends 'log('
      finalExpression = finalExpression.replaceAll('log(', 'log(10,');

      GrammarParser p = GrammarParser();
      Expression exp = p.parse(finalExpression);
      ContextModel cm = ContextModel();
      double eval = RealEvaluator(cm).evaluate(exp) as double;

      String resultStr = eval.toStringAsFixed(precision);
      if (resultStr.contains('.')) {
        resultStr = resultStr.replaceAll(RegExp(r'0*$'), '');
        if (resultStr.endsWith('.')) {
          resultStr = resultStr.substring(0, resultStr.length - 1);
        }
      }

      // Special case: if result is -0 or -0.0
      if (resultStr == '-0' || resultStr == '-0.0') {
        resultStr = '0';
      }

      final historyItem = HistoryItem(
        id: Uuid().v4(),
        expression: state.expression,
        result: resultStr,
        timestamp: DateTime.now(),
      );

      _saveHistory(historyItem);

      state = state.copyWith(result: resultStr, expression: '');
    } catch (e) {
      debugPrint('Evaluation Error: $e');
      state = state.copyWith(result: 'Error');
    }
  }

  String _convertTrigToRadians(String expression) {
    // This is a simplified replacement. For complex nested trig functions,
    // a proper recursive parser modification would be better,
    // but for most calculator use cases, this regex approach works if we handle the levels.
    // However, since we are doing string replacement before parsing, we have to be careful.

    // A more reliable way for 'sin(X)' where X might be complex:
    // We already added missing parentheses, so we can assume they are balanced.

    String result = expression;
    final trigFunctions = ['sin', 'cos', 'tan'];

    for (var func in trigFunctions) {
      // Find occurrences of 'func('
      int index = result.indexOf('$func(');
      while (index != -1) {
        // Find the matching closing parenthesis for this specific opening one
        int openParenIndex = index + func.length;
        int closeParenIndex = _findMatchingParen(result, openParenIndex);

        if (closeParenIndex != -1) {
          String inner = result.substring(openParenIndex + 1, closeParenIndex);
          // Replace sin(inner) with sin((inner) * pi / 180)
          String replacement = '$func(($inner) * 3.141592653589793 / 180)';
          result = result.replaceRange(index, closeParenIndex + 1, replacement);

          // Move index past this replacement to avoid infinite loops
          index = result.indexOf('$func(', index + replacement.length);
        } else {
          break; // Should not happen with balanced parens
        }
      }
    }
    return result;
  }

  int _findMatchingParen(String s, int openIndex) {
    int count = 0;
    for (int i = openIndex; i < s.length; i++) {
      if (s[i] == '(') {
        count++;
      } else if (s[i] == ')') {
        count--;
      }
      if (count == 0) return i;
    }
    return -1;
  }

  Future<void> toggleFavorite(String id) async {
    final box = HiveService.historyBox;
    final item = box.get(id);
    if (item != null) {
      item.isFavorite = !item.isFavorite;
      await item.save(); // Since it extends HiveObject

      // Refresh state
      _loadHistory();
    }
  }

  Future<void> clearHistory() async {
    state = state.copyWith(history: []);
    await HiveService.historyBox.clear();
  }

  void loadHistoryItem(HistoryItem item) {
    state = state.copyWith(
      expression: item.expression,
      result: '0', // Reset result so user can continue from the expression
    );
  }
}

final calculatorProvider =
    StateNotifierProvider<CalculatorNotifier, CalculatorState>((ref) {
      return CalculatorNotifier();
    });
