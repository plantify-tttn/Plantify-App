import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class LoginService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";
  
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse(
      "$baseUrl/login/check?email=$email&password=$password",
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data;
    } else {
      throw Exception("Lỗi khi đăng nhập: ${response.statusCode}");
    }
  }
}