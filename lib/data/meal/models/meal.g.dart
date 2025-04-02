// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'meal.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MealModelAdapter extends TypeAdapter<MealModel> {
  @override
  final int typeId = 2;

  @override
  MealModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MealModel(
      title: fields[0] as String,
      mealId: fields[1] as String,
      categoryId: (fields[2] as List).cast<String>(),
      image: fields[3] as String,
      ingredients: (fields[4] as List).cast<String>(),
      steps: (fields[5] as List).cast<String>(),
      isVegetarian: fields[6] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MealModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.title)
      ..writeByte(1)
      ..write(obj.mealId)
      ..writeByte(2)
      ..write(obj.categoryId)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.ingredients)
      ..writeByte(5)
      ..write(obj.steps)
      ..writeByte(6)
      ..write(obj.isVegetarian);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
