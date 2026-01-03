// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'freezer_item_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FreezerItemModelAdapter extends TypeAdapter<FreezerItemModel> {
  @override
  final int typeId = 12;

  @override
  FreezerItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FreezerItemModel(
      itemId: fields[0] as String,
      name: fields[1] as String,
      category: fields[2] as String,
      isSynced: fields[3] as bool,
      isDeleted: fields[4] as bool,
      ownerUid: fields[5] == null ? '' : fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FreezerItemModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.isSynced)
      ..writeByte(4)
      ..write(obj.isDeleted)
      ..writeByte(5)
      ..write(obj.ownerUid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FreezerItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
