import 'package:hive_flutter/hive_flutter.dart';
import '../models/history_item.dart';
import '../models/emi_plan.dart';

class HiveService {
  static const String settingsBoxName = 'settingsBox';
  static const String historyBoxName = 'historyBox';
  static const String userBoxName = 'userBox';
  static const String emiPlansBoxName = 'emiPlansBox';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(HistoryItemAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(EmiPlanAdapter());
    }

    // Open boxes
    await Hive.openBox(settingsBoxName);
    await Hive.openBox<HistoryItem>(historyBoxName);
    await Hive.openBox<EmiPlan>(emiPlansBoxName);
    await Hive.openBox(userBoxName);
  }

  static Box get settingsBox => Hive.box(settingsBoxName);
  static Box<HistoryItem> get historyBox =>
      Hive.box<HistoryItem>(historyBoxName);
  static Box<EmiPlan> get emiPlansBox => Hive.box<EmiPlan>(emiPlansBoxName);
  static Box get userBox => Hive.box(userBoxName);
}
