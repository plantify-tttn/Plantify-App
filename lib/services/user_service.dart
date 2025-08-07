import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:plantify/models/user_model.dart';

class UserService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  /// Lấy thông tin người dùng theo ID
  Future<UserModel> getUserById(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final userJson = <String, dynamic>{
        ...Map<String, dynamic>.from(data['user']),
        'accessToken': data['accessToken'] ?? '',
      };
      final user = UserModel.fromJson(userJson);
      hiveSaveUserById(user);
      return user;
    } else {
      throw Exception('Lỗi khi lấy người dùng: ${response.statusCode}');
    }
  }

  /// Lấy danh sách tất cả người dùng
  Future<List<UserModel>> getAllUsers() async {
    final url = Uri.parse('$baseUrl/users');
    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final List usersJson = data['users'];
      return usersJson.map((e) => UserModel.fromJson(e)).toList();
    } else {
      throw Exception('Lỗi khi lấy danh sách người dùng');
    }
  }

  /// Cập nhật thông tin người dùng
  Future<void> updateUser(UserModel user) async {
    final url = Uri.parse('$baseUrl/users/${user.id}');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(user.toJson()),
    );

    if (response.statusCode != 200) {
      throw Exception('Cập nhật thất bại');
    }
  }

  /// Xoá người dùng
  Future<void> deleteUser(String id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    final response = await http.delete(url);

    if (response.statusCode != 200) {
      throw Exception('Xoá thất bại');
    }
  }




  static const String _boxName = 'userBox';
  static const String _userKey = 'currentUser';

  // ✅ Lưu user
  static Future<void> hiveSaveUser(UserModel user) async {
    final box = Hive.box<UserModel>(_boxName);
    await box.put(_userKey, user);
  }
  static Future<void> hiveSaveUserById(UserModel user) async {
    final box = Hive.box<UserModel>('userBox');
    await box.put(user.id, user); // key là user.id
  }

  // ✅ Lấy user
  static UserModel? hiveGetUser() {
    final box = Hive.box<UserModel>(_boxName);
    return box.get(_userKey);
  }
  static UserModel? hiveGetUserById(String userId) {
    final box = Hive.box<UserModel>('userBox');
    return box.get(userId); // lấy theo key userId
  }

  // ✅ Xoá user khi logout
  static Future<void> hiveDeleteUser() async {
    final box = Hive.box<UserModel>(_boxName);
    await box.delete(_userKey);
  }

  // ✅ Kiểm tra đã login chưa
  static bool isLoggedIn() {
    final box = Hive.box<UserModel>(_boxName);
    return box.containsKey(_userKey);
  }

  static String getToken() {
    final box = Hive.box<UserModel>(_boxName);
    final user = box.get(_userKey);
    
    if (user != null && user.accessToken.isNotEmpty) {
      return user.accessToken;
    } else {
      throw Exception('Token not found in Hive');
    }
  }
}
