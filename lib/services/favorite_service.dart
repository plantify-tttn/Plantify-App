import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FavoriteService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  static Future<bool> addFavorite(String postId, String token) async {
    final res = await http.post(
      Uri.parse('$baseUrl/favorite/add'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({"postId": postId}),
    );
    return res.statusCode == 200;
  }

  static Future<bool> removeFavorite(String postId, String token) async {
    final res = await http.delete(
      Uri.parse("$baseUrl/favorite/$postId"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );
    return res.statusCode == 200;
  }

  static Future<List<String>> getFavorites(String token) async {
    final res = await http.get(
      Uri.parse("$baseUrl/favorite/get"),
      headers: {
        "Authorization": "Bearer $token",
      },
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      final List favorites = data['favorites'];

      return favorites.map((e) => e.toString()).toList(); // ép về List<String>
    } else {
      throw Exception("Failed to load favorites");
    }
  }

}
