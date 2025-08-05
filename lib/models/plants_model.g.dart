// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'plants_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PlantModelAdapter extends TypeAdapter<PlantModel> {
  @override
  final int typeId = 3;

  @override
  PlantModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PlantModel(
      id: fields[0] as String,
      name: fields[1] as String,
      nameEn: fields[2] as String,
      images: (fields[3] as List).cast<String>(),
      overview: fields[4] as String,
      overviewEn: fields[5] as String,
      characteristics: (fields[6] as Map).cast<String, String>(),
      characteristicsEn: (fields[7] as Map).cast<String, String>(),
      cultivation: (fields[8] as Map).cast<String, String>(),
      cultivationEn: (fields[9] as Map).cast<String, String>(),
      season: fields[10] as String,
      seasonEN: fields[11] as String,
      note: fields[12] as String,
      noteEn: fields[13] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PlantModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.images)
      ..writeByte(4)
      ..write(obj.overview)
      ..writeByte(5)
      ..write(obj.overviewEn)
      ..writeByte(6)
      ..write(obj.characteristics)
      ..writeByte(7)
      ..write(obj.characteristicsEn)
      ..writeByte(8)
      ..write(obj.cultivation)
      ..writeByte(9)
      ..write(obj.cultivationEn)
      ..writeByte(10)
      ..write(obj.season)
      ..writeByte(11)
      ..write(obj.seasonEN)
      ..writeByte(12)
      ..write(obj.note)
      ..writeByte(13)
      ..write(obj.noteEn);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PlantModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
