import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/currency_rate.dart';

class CurrencyService {
  final String baseUrl = 'https://latest.currency-api.pages.dev/v1/currencies';

  /// Fetches the latest rates from Currency-API.
  /// API returns rates relative to 1 NPR.
  Future<List<CurrencyRate>> fetchLatestRates() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/npr.json'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final Map<String, dynamic> ratesJson = data['npr'];
        final List<CurrencyRate> rates = [];

        // Add NPR as base (1:1)
        rates.add(
          CurrencyRate.auto(
            base: 'NPR',
            target: 'NPR',
            rate: 1.0,
            buyRate: 1.0,
            sellRate: 1.0,
          ),
        );

        for (var entry in ratesJson.entries) {
          final String iso3 = entry.key.toUpperCase();
          if (iso3 == 'NPR') continue;

          final double rateValue = (entry.value as num).toDouble();

          if (rateValue > 0) {
            // API returns 1 NPR = X Foreign.
            // We want 1 Foreign = 1/X NPR.
            final double normalizedRate = 1.0 / rateValue;

            rates.add(
              CurrencyRate.auto(
                base: 'NPR',
                target: iso3,
                rate: normalizedRate,
                buyRate: normalizedRate,
                sellRate: normalizedRate,
              ),
            );
          }
        }
        return rates;
      } else {
        throw Exception('API Error: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('CurrencyService Error: $e');
      rethrow;
    }
  }
}
