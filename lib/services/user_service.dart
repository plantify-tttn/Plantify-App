import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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
      return UserModel.fromJson(data['user']);
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
}
