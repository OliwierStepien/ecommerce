// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ingredient_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IngredientModelAdapter extends TypeAdapter<IngredientModel> {
  @override
  final int typeId = 3;

  @override
  IngredientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IngredientModel(
      amountPerPortion: fields[0] as num,
      ingredientCategory: fields[1] as String,
      ingredientId: fields[2] as String,
      ingredientName: fields[3] as String,
      mealId: fields[4] as String,
      unit: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, IngredientModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.amountPerPortion)
      ..writeByte(1)
      ..write(obj.ingredientCategory)
      ..writeByte(2)
      ..write(obj.ingredientId)
      ..writeByte(3)
      ..write(obj.ingredientName)
      ..writeByte(4)
      ..write(obj.mealId)
      ..writeByte(5)
      ..write(obj.unit);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IngredientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
