// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'emi_plan.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class EmiPlanAdapter extends TypeAdapter<EmiPlan> {
  @override
  final int typeId = 2;

  @override
  EmiPlan read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return EmiPlan(
      id: fields[0] as String,
      name: fields[1] as String,
      amount: fields[2] as double,
      rate: fields[3] as double,
      tenure: fields[4] as double,
      isYearly: fields[5] as bool,
      createdAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, EmiPlan obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.amount)
      ..writeByte(3)
      ..write(obj.rate)
      ..writeByte(4)
      ..write(obj.tenure)
      ..writeByte(5)
      ..write(obj.isYearly)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EmiPlanAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
