import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:plantify/models/post_model.dart';

class PostService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// Lấy danh sách bài viết
  Future<List<PostModel>> getPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List postsJson = data['posts'];
      return postsJson.map((e) => PostModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load postssssss');
    }
  }

  /// Lấy 1 bài viết theo id
  Future<PostModel> getPostById(String id) async {
    final response = await http.get(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return PostModel.fromJson(data['post']);
    } else {
      throw Exception('Post not found');
    }
  }

  /// Tạo bài viết mới
  Future<void> createPost(PostModel post) async {
    final response = await http.post(
      Uri.parse('$baseUrl/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post.toJson()), // cần thêm toJson trong Post class
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to create post');
    }
  }

  /// Xóa bài viết
  Future<void> deletePost(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post');
    }
  }
}
