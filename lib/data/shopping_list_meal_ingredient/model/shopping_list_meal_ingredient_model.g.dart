// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_meal_ingredient_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListMealIngredientModelAdapter
    extends TypeAdapter<ShoppingListMealIngredientModel> {
  @override
  final int typeId = 7;

  @override
  ShoppingListMealIngredientModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListMealIngredientModel(
      meal: fields[0] as MealModel,
      ingredient: fields[1] as IngredientModel,
      portionCount: fields[2] as int,
      isSynced: fields[3] as bool,
      isDeleted: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListMealIngredientModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.meal)
      ..writeByte(1)
      ..write(obj.ingredient)
      ..writeByte(2)
      ..write(obj.portionCount)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.isDeleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListMealIngredientModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
