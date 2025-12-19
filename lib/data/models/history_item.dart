import 'package:hive/hive.dart';

part 'history_item.g.dart';

@HiveType(typeId: 1)
class HistoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String expression;

  @HiveField(2)
  final String result;

  @HiveField(3)
  final DateTime timestamp;

  @HiveField(4)
  bool isFavorite;

  HistoryItem({
    required this.id,
    required this.expression,
    required this.result,
    required this.timestamp,
    this.isFavorite = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expression': expression,
      'result': result,
      'timestamp': timestamp.toIso8601String(),
      'isFavorite': isFavorite,
    };
  }

  factory HistoryItem.fromMap(Map<dynamic, dynamic> map) {
    return HistoryItem(
      id: map['id'],
      expression: map['expression'],
      result: map['result'],
      timestamp: DateTime.parse(map['timestamp']),
      isFavorite: map['isFavorite'] ?? false,
    );
  }
}
