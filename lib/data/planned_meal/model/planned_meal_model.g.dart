// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'planned_meal_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlannedMealModelAdapter extends TypeAdapter<PlannedMealModel> {
  @override
  final int typeId = 5;

  @override
  PlannedMealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlannedMealModel(
      date: fields[0] as DateTime,
      meal: fields[1] as MealModel,
      position: fields[4] == null ? 0 : fields[4] as int,
      isSynced: fields[2] == null ? false : fields[2] as bool,
      isDeleted: fields[3] == null ? false : fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PlannedMealModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.meal)
      ..writeByte(2)
      ..write(obj.isSynced)
      ..writeByte(3)
      ..write(obj.isDeleted)
      ..writeByte(4)
      ..write(obj.position);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlannedMealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
