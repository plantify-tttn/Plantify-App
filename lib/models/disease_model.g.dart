// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'disease_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DiseaseModelAdapter extends TypeAdapter<DiseaseModel> {
  @override
  final int typeId = 5;

  @override
  DiseaseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DiseaseModel(
      id: fields[0] as String,
      name: fields[1] as String,
      nameEn: fields[2] as String,
      description: fields[3] as String,
      descriptionEn: fields[4] as String,
      symptoms: fields[5] as String,
      symptomsEn: fields[6] as String,
      causes: fields[7] as String,
      causesEn: fields[8] as String,
      prevention: fields[9] as String,
      preventionEn: fields[10] as String,
      treatment: fields[11] as String,
      treatmentEn: fields[12] as String,
      images: (fields[13] as List).cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, DiseaseModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.nameEn)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.descriptionEn)
      ..writeByte(5)
      ..write(obj.symptoms)
      ..writeByte(6)
      ..write(obj.symptomsEn)
      ..writeByte(7)
      ..write(obj.causes)
      ..writeByte(8)
      ..write(obj.causesEn)
      ..writeByte(9)
      ..write(obj.prevention)
      ..writeByte(10)
      ..write(obj.preventionEn)
      ..writeByte(11)
      ..write(obj.treatment)
      ..writeByte(12)
      ..write(obj.treatmentEn)
      ..writeByte(13)
      ..write(obj.images);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DiseaseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
