// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_custom_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShoppingListCustomItemModelAdapter
    extends TypeAdapter<ShoppingListCustomItemModel> {
  @override
  final int typeId = 8;

  @override
  ShoppingListCustomItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShoppingListCustomItemModel(
      customItemId: fields[0] as String,
      customItemName: fields[1] as String,
      customItemCategory: fields[2] as String,
      isSynced: fields[3] as bool,
      isDeleted: fields[4] as bool,
      ownerUid: fields[5] == null ? '' : fields[5] as String,
      sourceOwnerUid: fields[6] == null ? '' : fields[6] as String,
      sourceItemId: fields[7] == null ? '' : fields[7] as String,
      editors: fields[8] == null ? [] : (fields[8] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, ShoppingListCustomItemModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.customItemId)
      ..writeByte(1)
      ..write(obj.customItemName)
      ..writeByte(2)
      ..write(obj.customItemCategory)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.isDeleted)
      ..writeByte(5)
      ..write(obj.ownerUid)
      ..writeByte(6)
      ..write(obj.sourceOwnerUid)
      ..writeByte(7)
      ..write(obj.sourceItemId)
      ..writeByte(8)
      ..write(obj.editors);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShoppingListCustomItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
