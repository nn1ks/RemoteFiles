// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'connection.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConnectionAdapter extends TypeAdapter<Connection> {
  @override
  Connection read(BinaryReader reader) {
    var numOfFields = reader.readByte();
    var fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Connection(
      name: fields[0] as String,
      address: fields[1] as String,
      port: fields[2] as String,
      username: fields[3] as String,
      passwordOrKey: fields[4] as String,
      path: fields[5] as String,
    );
  }

  @override
  void write(BinaryWriter writer, Connection obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.address)
      ..writeByte(2)
      ..write(obj.port)
      ..writeByte(3)
      ..write(obj.username)
      ..writeByte(4)
      ..write(obj.passwordOrKey)
      ..writeByte(5)
      ..write(obj.path);
  }
}
