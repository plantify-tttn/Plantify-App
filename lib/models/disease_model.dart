import 'dart:convert';

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

  // Helper nhỏ: ép mọi dạng về List<String> mà không thêm field mới
  static List<String> _toStringList(dynamic v) {
    if (v == null) return const [];
    if (v is List) return v.map((e) => e.toString()).toList();
    if (v is String && v.trim().isNotEmpty) {
      // Nếu server trả 1 URL string -> biến thành list 1 phần tử
      // Nếu là JSON string của 1 mảng -> parse thành list
      try {
        final parsed = jsonDecode(v);
        if (parsed is List) return parsed.map((e) => e.toString()).toList();
      } catch (_) {/* not a JSON array string */}
      return [v];
    }
    return const [];
  }

  factory DiseaseModel.fromJson(Map<String, dynamic> json) {
    return DiseaseModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      nameEn: json['name_en']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      descriptionEn: json['description_en']?.toString() ?? '',
      symptoms: json['symptoms']?.toString() ?? '',
      symptomsEn: json['symptoms_en']?.toString() ?? '',
      causes: json['causes']?.toString() ?? '',
      causesEn: json['causes_en']?.toString() ?? '',
      prevention: json['prevention']?.toString() ?? '',
      preventionEn: json['prevention_en']?.toString() ?? '',
      treatment: json['treatment']?.toString() ?? '',
      treatmentEn: json['treatment_en']?.toString() ?? '',
      images: _toStringList(json['images']),
    );
  }

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
