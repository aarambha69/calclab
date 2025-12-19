import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../data/services/currency_service.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/history_item.dart';
import '../../data/models/currency_rate.dart';

class CurrencyState {
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double result;
  final double manualRate;
  final bool isAutoMode;
  final bool isLoading;
  final String? error;
  final Map<String, CurrencyRate>
  cachedRates; // ISO3 -> CurrencyRate (relative to NPR)

  CurrencyState({
    this.fromCurrency = 'USD',
    this.toCurrency = 'NPR',
    this.amount = 1.0,
    this.result = 0.0,
    this.manualRate = 1.0,
    this.isAutoMode = true,
    this.isLoading = false,
    this.error,
    this.cachedRates = const {},
  });

  CurrencyState copyWith({
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? result,
    double? manualRate,
    bool? isAutoMode,
    bool? isLoading,
    String? error,
    Map<String, CurrencyRate>? cachedRates,
  }) {
    return CurrencyState(
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      result: result ?? this.result,
      manualRate: manualRate ?? this.manualRate,
      isAutoMode: isAutoMode ?? this.isAutoMode,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      cachedRates: cachedRates ?? this.cachedRates,
    );
  }

  double get currentRate {
    if (isAutoMode) {
      if (fromCurrency == toCurrency) return 1.0;

      final fromNprRate = cachedRates[fromCurrency]?.rate;
      final toNprRate = cachedRates[toCurrency]?.rate;

      if (fromNprRate != null && toNprRate != null && toNprRate != 0) {
        // Rate(A to B) = (A relative to NPR) / (B relative to NPR)
        // Wait, the rates are normalized as 1 Unit = X NPR.
        // So 1 USD = 130 NPR, 1 EUR = 140 NPR.
        // 1 USD = (130 / 140) EUR.
        return fromNprRate / toNprRate;
      }
      return 0.0;
    } else {
      return manualRate;
    }
  }
}

class CurrencyNotifier extends StateNotifier<CurrencyState> {
  final CurrencyService _service = CurrencyService();

  CurrencyNotifier() : super(CurrencyState()) {
    fetchRates();
  }

  Future<void> fetchRates() async {
    if (!state.isAutoMode) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final ratesList = await _service.fetchLatestRates();
      if (ratesList.isEmpty) {
        state = state.copyWith(
          isLoading: false,
          error: 'Rates currently unavailable. Please try again later.',
        );
        return;
      }

      final Map<String, CurrencyRate> ratesMap = {
        for (var rate in ratesList) rate.targetCode: rate,
      };

      state = state.copyWith(cachedRates: ratesMap, isLoading: false);
      _calculateResult();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to fetch currency exchange rates',
      );
    }
  }

  void setFromCurrency(String currency) {
    if (state.fromCurrency == currency) return;
    state = state.copyWith(fromCurrency: currency);
    _calculateResult();
  }

  void setToCurrency(String currency) {
    if (state.toCurrency == currency) return;
    state = state.copyWith(toCurrency: currency);
    _calculateResult();
  }

  void setAmount(double amount) {
    state = state.copyWith(amount: amount);
    _calculateResult();
  }

  void setManualRate(double rate) {
    state = state.copyWith(manualRate: rate);
    if (!state.isAutoMode) {
      _calculateResult();
    }
  }

  void toggleMode() {
    final newMode = !state.isAutoMode;
    state = state.copyWith(isAutoMode: newMode);
    if (newMode && state.cachedRates.isEmpty) {
      fetchRates();
    } else {
      _calculateResult();
    }
  }

  void swapCurrencies() {
    final from = state.fromCurrency;
    final to = state.toCurrency;
    state = state.copyWith(fromCurrency: to, toCurrency: from);
    _calculateResult();
  }

  void _calculateResult() {
    double rate = state.currentRate;
    final result = state.amount * rate;
    state = state.copyWith(result: result);

    if (result > 0 && state.amount > 0) {
      _saveToHistory();
    }
  }

  void _saveToHistory() {
    final historyItem = HistoryItem(
      id: const Uuid().v4(),
      expression: '${state.amount} ${state.fromCurrency} ➔ ${state.toCurrency}',
      result: '${state.result.toStringAsFixed(2)} ${state.toCurrency}',
      timestamp: DateTime.now(),
    );

    final box = HiveService.historyBox;
    box.put(historyItem.id, historyItem);
  }
}

final currencyProvider = StateNotifierProvider<CurrencyNotifier, CurrencyState>(
  (ref) {
    return CurrencyNotifier();
  },
);

final commonCurrencies = [
  'NPR',
  'INR',
  'USD',
  'EUR',
  'GBP',
  'CHF',
  'AUD',
  'CAD',
  'SGD',
  'JPY',
  'CNY',
  'SAR',
  'QAR',
  'THB',
  'AED',
  'MYR',
  'KRW',
  'SEK',
  'DKK',
  'HKD',
  'KWD',
  'BHD',
  'OMR',
];
