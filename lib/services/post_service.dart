import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart' show Hive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:plantify/models/post_model.dart';
import 'package:plantify/services/user_service.dart';

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
      // print("⚠️ Không thể làm mới dữ liệu bài viết: $e");
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

  Future<Map<String, dynamic>> createPost({
    required String content,
    File? image,
    String? token,
  }) async {
    if (baseUrl.isEmpty) {
      throw Exception('BASE_URL is empty. Did you call dotenv.load?');
    }

    final uri = Uri.parse('$baseUrl/posts/create'); // đổi path theo BE của bạn
    final req = http.MultipartRequest('POST', uri);

    // Text fields
    req.fields['content'] = content;

    // Auth
    final t = token ?? UserService.getToken();
    if (t.isNotEmpty) {
      req.headers['Authorization'] = 'Bearer $t';
    }

    // File (nếu có)
    if (image != null) {
      req.files.add(
        await http.MultipartFile.fromPath(
          'image', // đổi tên field theo BE (vd: 'photo' hoặc 'file')
          image.path,
          filename: p.basename(image.path),
        ),
      );
    }

    final res = await req.send();
    final body = await res.stream.bytesToString();

    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('Create post failed (${res.statusCode}): $body');
    }

    final json = jsonDecode(body);
    return (json is Map<String, dynamic>) ? json : {'data': json};
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
