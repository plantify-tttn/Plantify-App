import 'package:hive/hive.dart';
import 'dart:ui';

part 'disease_model.g.dart';

@HiveType(typeId: 5) // ⚠️ must be unique across all your Hive models
class DiseaseModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameEn;

  @HiveField(3)
  final String description;

  @HiveField(4)
  final String descriptionEn;

  @HiveField(5)
  final String symptoms;

  @HiveField(6)
  final String symptomsEn;

  @HiveField(7)
  final String causes;

  @HiveField(8)
  final String causesEn;

  @HiveField(9)
  final String prevention;

  @HiveField(10)
  final String preventionEn;

  @HiveField(11)
  final String treatment;

  @HiveField(12)
  final String treatmentEn;

  @HiveField(13)
  final List<String> images;

  DiseaseModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.description,
    required this.descriptionEn,
    required this.symptoms,
    required this.symptomsEn,
    required this.causes,
    required this.causesEn,
    required this.prevention,
    required this.preventionEn,
    required this.treatment,
    required this.treatmentEn,
    required this.images
  });

  /// Factory to create from JSON
  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      description: json['description'] ?? '',
      descriptionEn: json['description_en'] ?? '',
      symptoms: json['symptoms'] ?? '',
      symptomsEn: json['symptoms_en'] ?? '',
      causes: json['causes'] ?? '',
      causesEn: json['causes_en'] ?? '',
      prevention: json['prevention'] ?? '',
      preventionEn: json['prevention_en'] ?? '',
      treatment: json['treatment'] ?? '',
      treatmentEn: json['treatment_en'] ?? '',
      images: List<String>.from(json['images'] ?? [
        "https://i.pinimg.com/736x/56/62/06/566206f8c38093a733f1464565e5c3b8.jpg",
        "https://i.pinimg.com/736x/ee/c1/2b/eec12bbb25f5cb67e3c6856576a3b831.jpg",
        "https://i.pinimg.com/1200x/bc/4f/10/bc4f10e98bc5e6a2b15e51b49d2fe89b.jpg",
        "https://i.pinimg.com/1200x/12/08/10/120810d523ebd73f1dbeb2d85ea54bde.jpg",
        "https://i.pinimg.com/1200x/a9/eb/e9/a9ebe90ae4deba12d6fb1702c347f400.jpg"
    ]),
    );
  }

  /// Convert to JSON (for API / export)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'description': description,
      'description_en': descriptionEn,
      'symptoms': symptoms,
      'symptoms_en': symptomsEn,
      'causes': causes,
      'causes_en': causesEn,
      'prevention': prevention,
      'prevention_en': preventionEn,
      'treatment': treatment,
      'treatment_en': treatmentEn,
      'images': images,
    };
  }

  // 👇 Helpers to get content based on locale
  String localizedName(Locale locale) => locale.languageCode == 'vi' ? name : nameEn;
  String localizedDescription(Locale locale) => locale.languageCode == 'vi' ? description : descriptionEn;
  String localizedSymptoms(Locale locale) => locale.languageCode == 'vi' ? symptoms : symptomsEn;
  String localizedCauses(Locale locale) => locale.languageCode == 'vi' ? causes : causesEn;
  String localizedPrevention(Locale locale) => locale.languageCode == 'vi' ? prevention : preventionEn;
  String localizedTreatment(Locale locale) => locale.languageCode == 'vi' ? treatment : treatmentEn;
}
