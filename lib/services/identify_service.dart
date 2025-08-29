import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

/// IdentifyService: upload ảnh hạt giống (seed) để nhận diện.
/// API tham chiếu từ Postman: POST {BASE_URL}/upload/detect/seed  -> { "url": "..." }
class IdentifyService {
  IdentifyService._internal();
  static final IdentifyService _instance = IdentifyService._internal();
  factory IdentifyService() => _instance;

  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  Future<String> sendSeedImage(
    File imageFile,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/upload/detect/seed');

    try {
      final req = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        })
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamed =
          await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);

      final ok = res.statusCode == 201 || res.statusCode == 200;

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        data = {'raw': res.body};
      }

      if (ok) {
        return data['id'] ?? 'corn001';
      } else {
        return '';
      }
    } catch(e){
      print('==== $e');
      return '';
    }
  }

  
}
