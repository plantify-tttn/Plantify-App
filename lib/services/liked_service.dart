import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LikeService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  Future<bool> isPostLiked(String userId, String postId) async {
    final url = Uri.parse('$baseUrl/liked/check?userId=$userId&postId=$postId');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['liked'] == true;
    } else {
      throw Exception('Lỗi khi kiểm tra like');
    }
  }
}
