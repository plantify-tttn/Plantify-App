class PlantModel {
  final String id;
  final String name;
  final List<String> images;
  final String overview;
  final Map<String, String> characteristics;
  final Map<String, String> cultivation;
  final String season;
  final String note;

  PlantModel({
    required this.id,
    required this.name,
    required this.images,
    required this.overview,
    required this.characteristics,
    required this.cultivation,
    required this.season,
    required this.note,
  });

  factory PlantModel.fromJson(Map<String, dynamic> json) {
    return PlantModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      images: List<String>.from(json['images'] ?? []),
      overview: json['overview'] ?? '',
      characteristics: Map<String, String>.from(json['characteristics'] ?? {}),
      cultivation: Map<String, String>.from(json['cultivation'] ?? {}),
      season: json['season'] ?? '',
      note: json['note'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'images': images,
      'overview': overview,
      'characteristics': characteristics,
      'cultivation': cultivation,
      'season': season,
      'note': note,
    };
  }
}
