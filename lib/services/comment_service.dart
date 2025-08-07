import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plantify/models/comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommentService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// Lấy danh sách comment của bài post
  static Future<List<CommentModel>> getComments(String postId, String token) async {
    final res = await http.get(
      Uri.parse('$baseUrl/comment/post/$postId'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
    );

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      print("==============$data"); // 👈 In ra dữ liệu để debug
      return data.map((e) => CommentModel.fromJson(e)).toList();
    } else {
      print("=============="); // 👈 In ra dữ liệu để debug
      throw Exception("❌ Lỗi khi lấy comment: ${res.statusCode}");
    }
  }

  /// Gửi comment mới
  static Future<bool> createComment({
    required String postId,
    required String content,
    required String token,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/comment'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "postId": postId,
        "content": content,
      }),
    );

    return res.statusCode == 201; // hoặc 200 tùy backend
  }
}
