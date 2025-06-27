// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListItemModelAdapter extends TypeAdapter<ShoppingListItemModel> {
  @override
  final int typeId = 4;

  @override
  ShoppingListItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListItemModel(
      ingredientId: fields[0] as String,
      ingredientName: fields[1] as String,
      amountPerPortion: fields[2] as double?,
      scaledAmount: fields[3] as double?,
      unit: fields[4] as String,
      ingredientCategory: fields[5] as String,
      mealId: fields[6] as String?,
      title: fields[7] as String?,
      meal: fields[8] as MealModel?,
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListItemModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.ingredientId)
      ..writeByte(1)
      ..write(obj.ingredientName)
      ..writeByte(2)
      ..write(obj.amountPerPortion)
      ..writeByte(3)
      ..write(obj.scaledAmount)
      ..writeByte(4)
      ..write(obj.unit)
      ..writeByte(5)
      ..write(obj.ingredientCategory)
      ..writeByte(6)
      ..write(obj.mealId)
      ..writeByte(7)
      ..write(obj.title)
      ..writeByte(8)
      ..write(obj.meal);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
