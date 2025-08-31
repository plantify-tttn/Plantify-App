import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart' show Hive;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:plantify/models/post_model.dart';
import 'package:plantify/services/user_service.dart';

class PostService {
  PostService._internal();
  static final PostService _instance = PostService._internal();
  factory PostService(){
    return _instance;
  }
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";


  /// Gọi API và lưu kết quả vào Hive
  Future<List<PostModel>> fetchAndSavePosts({
    int page = 1,
    int limit = 5,
    String? token,
  }) async {
    final uri = Uri.parse('$baseUrl/posts').replace(queryParameters: {
      'page': '$page',
      'limit': '$limit',
    });

    final headers = <String, String>{
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      return [];
    }

    // decode chuẩn để tránh lỗi tiếng Việt
    final decoded =
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;

    // API trả mảng trong field "data"
    final List list = (decoded['data'] ?? decoded['posts'] ?? []) as List;

    return list
        .map((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  /// Gọi API và lưu kết quả vào Hive
  Future<List<PostModel>> fetchUPosts({
    required String token, // truyền token nếu có
  }) async {
    final uri = Uri.parse('$baseUrl/posts/user');

    final headers = <String, String>{
      'Accept': 'application/json',
      if (token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final response = await http.get(uri, headers: headers);

    if (response.statusCode != 200 && response.statusCode != 201) {
      return [];
    }

    // API trả về mảng trong field "data" (không phải "posts")
    final rawList = jsonDecode(response.body) as List;

    final posts = rawList
        .map<PostModel>((e) => PostModel.fromJson(e as Map<String, dynamic>))
        .toList();
    return posts;
  }

  /// Gọi API để cập nhật Hive trong nền
  void _refreshPostsInBackground() async {
    try {
      await fetchAndSavePosts();
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

  Future<void> createPost({
    required String content,
    required File image,
    required String token
  }) async {
    final uri = Uri.parse('$baseUrl/posts');
    final request = http.MultipartRequest('POST', uri);
    request.headers['Authorization'] = 'Bearer $token';
    request.fields['content'] = content;
    request.files.add(
      await http.MultipartFile.fromPath(
        'image', // tên field bên backend
        image.path,
      ),
    );
    final response = await request.send();

    if (response.statusCode == 200 || response.statusCode == 201) {
      print('Post created successfully');
    } else {
      print('Failed to create post: ${response.statusCode}');
      final respStr = await response.stream.bytesToString();
      print(respStr);
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
