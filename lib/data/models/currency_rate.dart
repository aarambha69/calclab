class CurrencyRate {
  final String baseCode;
  final String targetCode;
  final double rate; // Mid rate or default rate
  final double buyRate;
  final double sellRate;
  final int unit;
  final DateTime lastUpdated;
  final bool isManual;

  CurrencyRate({
    required this.baseCode,
    required this.targetCode,
    required this.rate,
    required this.buyRate,
    required this.sellRate,
    this.unit = 1,
    required this.lastUpdated,
    this.isManual = false,
  });

  double convert(double amount) {
    return amount * rate;
  }

  factory CurrencyRate.auto({
    required String base,
    required String target,
    required double rate,
    required double buyRate,
    required double sellRate,
    int unit = 1,
  }) {
    return CurrencyRate(
      baseCode: base,
      targetCode: target,
      rate: rate,
      buyRate: buyRate,
      sellRate: sellRate,
      unit: unit,
      lastUpdated: DateTime.now(),
      isManual: false,
    );
  }

  factory CurrencyRate.manual({
    required String base,
    required String target,
    required double rate,
  }) {
    return CurrencyRate(
      baseCode: base,
      targetCode: target,
      rate: rate,
      buyRate: rate,
      sellRate: rate,
      lastUpdated: DateTime.now(),
      isManual: true,
    );
  }
}
