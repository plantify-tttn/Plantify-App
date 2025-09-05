import 'dart:convert';
import 'dart:ui';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart' show Hive;
import 'package:http/http.dart' as http;
import 'package:plantify/models/disease_model.dart';
import 'package:plantify/models/plants_model.dart';

class PlantsService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  Future<List<PlantModel>> getPlants() async {
    final response = await http.get(Uri.parse('$baseUrl/plant'));

    if (response.statusCode == 200) {
       final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      final List plantsJson =
      decoded is List ? decoded : (decoded['plants'] as List? ?? []);
      final plants = plantsJson.map((e) => PlantModel.fromJson(e)).toList();
      await savePlantsToHive(plants);
      return plants;
    } else {
      throw Exception('Failed to load plants');
    }
  }
  Future<List<DiseaseModel>> getDisease() async {
    final res = await http.get(Uri.parse('$baseUrl/plant/diseases'));
    if (res.statusCode != 200) {
      throw Exception('Failed to load diseases: ${res.statusCode}');
    }

    final decoded = jsonDecode(utf8.decode(res.bodyBytes));

    // API có thể trả List trực tiếp, hoặc bọc trong "diseases"/"disease"
    final List<dynamic> items = decoded is List
        ? decoded
        : (decoded['diseases'] as List?) ??
          (decoded['disease'] as List?) ??
          <dynamic>[];

    final disease = items
        .whereType<Map<String, dynamic>>()
        .map(DiseaseModel.fromJson)
        .toList();

    await saveDiseaseToHive(disease);
    return disease;
  }
  /// Lấy dữ liệu từ Hive
  List<PlantModel> getPlantsFromHive() {
    final box = Hive.box<PlantModel>('plants');
    return box.values.toList();
  }
  List<DiseaseModel> getDiseaseFromHive() {
    final box = Hive.box<DiseaseModel>('diseases');
    return box.values.toList();
  }

  /// Lưu danh sách vào Hive
  Future<void> savePlantsToHive(List<PlantModel> plants) async {
    final box = Hive.box<PlantModel>('plants');
    await box.clear();
    for (var plant in plants) {
      await box.put(plant.id, plant);
    }
  }
  Future<void> saveDiseaseToHive(List<DiseaseModel> disease) async {
    final box = Hive.box<DiseaseModel>('diseases');
    await box.clear();
    for (var plant in disease) {
      await box.put(plant.id, plant);
    }
  }

  /// So sánh dữ liệu mới và cũ (đơn giản bằng json)
  bool isDifferent(List<PlantModel> oldList, List<PlantModel> newList) {
    final oldJson = jsonEncode(oldList.map((e) => e.toJson()).toList());
    final newJson = jsonEncode(newList.map((e) => e.toJson()).toList());
    return oldJson != newJson;
  }

  /// Gọi API, so sánh, cập nhật Hive nếu khác
  Future<List<PlantModel>> fetchAndUpdatePlants({
    VoidCallback? onDataChanged,
  }) async {
    final response = await http.get(Uri.parse('$baseUrl/plants'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List jsonList = data['plants'];
      final List<PlantModel> newPlants =
          jsonList.map((e) => PlantModel.fromJson(e)).toList();

      final List<PlantModel> oldPlants = getPlantsFromHive();
      if (isDifferent(oldPlants, newPlants)) {
        await savePlantsToHive(newPlants);
        if (onDataChanged != null) onDataChanged();
      }

      return newPlants;
    } else {
      throw Exception('❌ Failed to load plants');
    }
  }
  PlantModel? getPlantById(String id) {
    final box = Hive.box<PlantModel>('plants');
    return box.get(id); // Trả về null nếu không có
  }
}