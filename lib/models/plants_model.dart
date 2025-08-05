import 'package:hive/hive.dart';
import 'dart:ui';

part 'plants_model.g.dart';

@HiveType(typeId: 3)
class PlantModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String nameEn;

  @HiveField(3)
  final List<String> images;

  @HiveField(4)
  final String overview;

  @HiveField(5)
  final String overviewEn;

  @HiveField(6)
  final Map<String, String> characteristics;

  @HiveField(7)
  final Map<String, String> characteristicsEn;

  @HiveField(8)
  final Map<String, String> cultivation;

  @HiveField(9)
  final Map<String, String> cultivationEn;

  @HiveField(10)
  final String season;

  @HiveField(11)
  final String seasonEN;

  @HiveField(12)
  final String note;

  @HiveField(13)
  final String noteEn;

  PlantModel({
    required this.id,
    required this.name,
    required this.nameEn,
    required this.images,
    required this.overview,
    required this.overviewEn,
    required this.characteristics,
    required this.characteristicsEn,
    required this.cultivation,
    required this.cultivationEn,
    required this.season,
    required this.seasonEN,
    required this.note,
    required this.noteEn,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      nameEn: json['name_en'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      overview: json['overview'] ?? '',
      overviewEn: json['overview_en'] ?? '',
      characteristics: Map<String, String>.from(json['characteristics'] ?? {}),
      characteristicsEn: Map<String, String>.from(json['characteristics_en'] ?? {}),
      cultivation: Map<String, String>.from(json['cultivation'] ?? {}),
      cultivationEn: Map<String, String>.from(json['cultivation_en'] ?? {}),
      season: json['season'] ?? '',
      seasonEN: json['season_en'] ?? '',
      note: json['note'] ?? '',
      noteEn: json['note_en'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'name_en': nameEn,
      'images': images,
      'overview': overview,
      'overview_en': overviewEn,
      'characteristics': characteristics,
      'characteristics_en': characteristicsEn,
      'cultivation': cultivation,
      'cultivation_en': cultivationEn,
      'season': season,
      'season_en': seasonEN,
      'note': note,
      'note_en': noteEn,
    };
  }

  // 👇 Hàm tiện ích để lấy theo locale
  String localizedName(Locale locale) => locale.languageCode == 'vi' ? name : nameEn;
  String localizedOverview(Locale locale) => locale.languageCode == 'vi' ? overview : overviewEn;
  Map<String, String> localizedCharacteristics(Locale locale) =>
      locale.languageCode == 'vi' ? characteristics : characteristicsEn;
  Map<String, String> localizedCultivation(Locale locale) =>
      locale.languageCode == 'vi' ? cultivation : cultivationEn;
  String localizedSeason(Locale locale) => locale.languageCode == 'vi' ? season : seasonEN;
  String localizedNote(Locale locale) => locale.languageCode == 'vi' ? note : noteEn;
}
