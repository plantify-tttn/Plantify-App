import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:plantify/models/plants_model.dart';

class PlantsService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  Future<List<PlantModel>> getPlants() async {
    final response = await http.get(Uri.parse('$baseUrl/plants'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List plantsJson = data['plants'];
      final plants = plantsJson.map((e) => PlantModel.fromJson(e)).toList();
      return plants;
    } else {
      throw Exception('Failed to load plants');
    }
  }

}