// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'background_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BackgroundMessageAdapter extends TypeAdapter<BackgroundMessage> {
  @override
  final int typeId = 3;

  @override
  BackgroundMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BackgroundMessage(
      topic: fields[0] as String,
      message: fields[1] as Message,
    );
  }

  @override
  void write(BinaryWriter writer, BackgroundMessage obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.topic)
      ..writeByte(1)
      ..write(obj.message);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BackgroundMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
