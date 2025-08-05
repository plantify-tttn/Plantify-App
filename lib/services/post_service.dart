import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart' show Hive;
import 'package:http/http.dart' as http;
import 'package:plantify/models/post_model.dart';

class PostService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// Lấy danh sách bài viết
  Future<List<PostModel>> getPosts() async {
    final box = Hive.box<PostModel>('posts');
    final localPosts = box.values.toList();

    // Nếu Hive đã có dữ liệu, trả về ngay
    if (localPosts.isNotEmpty) {
      // 🔃 Đồng thời cập nhật lại từ server (không chờ)
      _refreshPostsInBackground();
      return localPosts;
    }

    // Nếu Hive không có → gọi API
    return await _fetchAndSavePosts();
  }

  /// Gọi API và lưu kết quả vào Hive
  Future<List<PostModel>> _fetchAndSavePosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List postsJson = data['posts'];
      final posts = postsJson.map((e) => PostModel.fromJson(e)).toList();

      // 🔄 Lưu vào Hive
      await savePostsToHive(posts);
      return posts;
    } else {
      throw Exception('Failed to fetch posts from API');
    }
  }

  /// Gọi API để cập nhật Hive trong nền
  void _refreshPostsInBackground() async {
    try {
      await _fetchAndSavePosts();
    } catch (e) {
      // Không cần throw, chỉ log
      print("⚠️ Không thể làm mới dữ liệu bài viết: $e");
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
  /// Lưu danh sách bài viết vào Hive
  Future<void> savePostsToHive(List<PostModel> posts) async {
    final box = Hive.box<PostModel>('posts');
    await box.clear(); // xoá cũ
    for (var post in posts) {
      await box.put(post.id, post);
    }
  }

  /// Lấy danh sách từ Hive
  List<PostModel> getPostsFromHive() {
    final box = Hive.box<PostModel>('posts');
    return box.values.toList();
  }
}
