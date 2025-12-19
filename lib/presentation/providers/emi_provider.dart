import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/local/hive_service.dart';
import '../../data/models/emi_plan.dart';

class EmiPlansNotifier extends StateNotifier<List<EmiPlan>> {
  EmiPlansNotifier() : super([]) {
    loadPlans();
  }

  void loadPlans() {
    final box = HiveService.emiPlansBox;
    final plans = box.values.whereType<EmiPlan>().toList();
    // Sort by createdAt desc
    plans.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    state = plans;
  }

  Future<void> addPlan(EmiPlan plan) async {
    final box = HiveService.emiPlansBox;
    await box.put(plan.id, plan);
    loadPlans();
  }

  Future<void> deletePlan(String id) async {
    final box = HiveService.emiPlansBox;
    await box.delete(id);
    loadPlans();
  }

  Future<void> clearAllPlans() async {
    final box = HiveService.emiPlansBox;
    await box.clear();
    loadPlans();
  }
}

final emiPlansProvider = StateNotifierProvider<EmiPlansNotifier, List<EmiPlan>>(
  (ref) {
    return EmiPlansNotifier();
  },
);

final selectedEmiPlanProvider = StateProvider<EmiPlan?>((ref) => null);
