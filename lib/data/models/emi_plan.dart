import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

part 'emi_plan.g.dart';

@HiveType(typeId: 2)
class EmiPlan extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final double rate;

  @HiveField(4)
  final double tenure;

  @HiveField(5)
  final bool isYearly;

  @HiveField(6)
  final DateTime createdAt;

  EmiPlan({
    required this.id,
    required this.name,
    required this.amount,
    required this.rate,
    required this.tenure,
    required this.isYearly,
    required this.createdAt,
  });

  factory EmiPlan.create({
    required String name,
    required double amount,
    required double rate,
    required double tenure,
    required bool isYearly,
  }) {
    return EmiPlan(
      id: Uuid().v4(),
      name: name,
      amount: amount,
      rate: rate,
      tenure: tenure,
      isYearly: isYearly,
      createdAt: DateTime.now(),
    );
  }
}
