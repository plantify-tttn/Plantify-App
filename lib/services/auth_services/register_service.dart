import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class RegisterService {
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";
  
  Future<Map<String, dynamic>> register({
    required String username,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse("$baseUrl/auth/register");

    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json","ngrok-skip-browser-warning": "true"},
      body: jsonEncode({
        "username": username,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return {"success": true, "data": jsonDecode(response.body)};
    } else {
      return {
        "message": "Lỗi ${response.statusCode}: ${response.reasonPhrase}"
        "access_token"
      };
    }
  }
}