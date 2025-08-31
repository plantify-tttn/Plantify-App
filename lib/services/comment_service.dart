import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:plantify/models/comment_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CommentService {
  static final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// Lấy danh sách comment của bài post
  static Future<List<CommentModel>> getComments(String postId, String token) async {
    final url = Uri.parse('$baseUrl/comment/$postId'); // <-- KHỚP Postman
    try{
      final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (res.statusCode == 200 || res.statusCode == 201 ) {
      final root = jsonDecode(res.body) as Map<String, dynamic>;
      final list = (root['data'] as List?) ?? const [];
      return list.map((e) => CommentModel.fromJson(e as Map<String, dynamic>)).toList();
    } else {
      // Log để debug
      print('[getComments] ${res.statusCode} ${res.body}');
      throw Exception('Lỗi khi lấy comment: ${res.statusCode}');
    }
    }catch(e){
      print('===coment $e');
      return[];
    }
  }

  /// Gửi comment mới
  static Future<bool> createComment({
    required String postId,
    required String content,
    required String token,
  }) async {
    try{
      final res = await http.post(
      Uri.parse('$baseUrl/comment'),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "content": content,
        "postId": postId
      }),
    );
    print('=== okiiiii');
    if(res.statusCode == 201 || res.statusCode == 200){
      return true;
    }else{
      return false;
    }
    }catch(e){
      print('==== createcommet $e');
      return false;
    }
  }
}
