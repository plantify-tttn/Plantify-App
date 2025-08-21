// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'post_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PostModelAdapter extends TypeAdapter<PostModel> {
  @override
  final int typeId = 2;

  @override
  PostModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PostModel(
      id: fields[0] as String,
      userid: fields[1] as String,
      content: fields[2] as String,
      imageurl: fields[3] as String,
      loveCount: fields[4] as int,
      commentCount: fields[5] as int,
      created_at: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PostModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.userid)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.imageurl)
      ..writeByte(4)
      ..write(obj.loveCount)
      ..writeByte(5)
      ..write(obj.commentCount)
      ..writeByte(6)
      ..write(obj.created_at);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
