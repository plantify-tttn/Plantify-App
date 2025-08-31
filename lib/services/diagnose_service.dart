import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class DiagnoseService {
  DiagnoseService._internal();
  static final DiagnoseService _instance = DiagnoseService._internal();
  factory DiagnoseService() {
    return _instance;
  }
  final String baseUrl = dotenv.env['BASE_URL'] ?? "";

  Future<Map<String, dynamic>> sendText(String text, String token) async {
    final url = Uri.parse('$baseUrl/chatbot');
    try {
      final response = await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'ngrok-skip-browser-warning': 'true',
              if (token.isNotEmpty) 'Authorization': 'Bearer $token',
            },
            body: jsonEncode({'message': text}),
          )
          .timeout(const Duration(seconds: 30));

      final isOk = response.statusCode == 201;

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(response.body) as Map<String, dynamic>;
      } catch (_) {}

      if (isOk) {
        final formatted = formatChatbotReply(data ?? const {});
        return {
          'success': true,
          'data': data ?? <String, dynamic>{'raw': response.body},
          'display': formatted['text'] as String,           // <-- text hiển thị
          'options': formatted['options'] as List<String>,  // <-- quick replies
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${response.statusCode}: ${response.reasonPhrase}',
          'data': data ?? <String, dynamic>{'raw': response.body},
        };
      }
    } on SocketException catch (e) {
      return {'success': false, 'message': 'Không có kết nối mạng: $e'};
    } on HttpException catch (e) {
      return {'success': false, 'message': 'Lỗi HTTP: $e'};
    } on FormatException catch (_) {
      return {'success': false, 'message': 'Response không phải JSON hợp lệ'};
    } on TimeoutException {
      return {'success': false, 'message': 'Request quá thời gian chờ'};
    } catch (e) {
      return {'success': false, 'message': 'Lỗi không xác định: $e'};
    }
  }

  /// Trả về: { 'text': String, 'options': List<String> }
  Map<String, Object> formatChatbotReply(Map<String, dynamic> data) {
    final answer = data['answer']?.toString();
    final detail = data['detail']?.toString();
    final suggest = data['suggest']?.toString();
    final nextQ = data['next_question']; // có thể là String hoặc List

    final buf = StringBuffer();
    if ((answer ?? '').isNotEmpty) buf.writeln('🩺 $answer');
    if ((detail ?? '').isNotEmpty) buf.writeln('• $detail');
    if ((suggest ?? '').isNotEmpty) buf.writeln('• $suggest');

    // --- Parse next questions robustly ---
    List<String> options = [];
    if (nextQ != null) {
      if (nextQ is List) {
        options = nextQ.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList();
      } else if (nextQ is String) {
        // chấp nhận phân tách bởi |, , hoặc xuống dòng
        options = nextQ
            .split(RegExp(r'\n|,|\|'))
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }
    }

    if (options.isNotEmpty) {
      buf.writeln('🤖 Bạn có thể hỏi tiếp:');
    }

    final textOut = buf.isEmpty ? 'Đã nhận phản hồi.' : buf.toString().trim();
    return {'text': textOut, 'options': options};
  }

  Future<Map<String, dynamic>> sendImage(
    File imageFile,
    String token,
  ) async {
    final url = Uri.parse('$baseUrl/upload/detect/diseases');

    try {
      final req = http.MultipartRequest('POST', url)
        ..headers.addAll({
          'Accept': 'application/json',
          'ngrok-skip-browser-warning': 'true',
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        })
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final streamed = await req.send().timeout(const Duration(seconds: 60));
      final res = await http.Response.fromStream(streamed);

      final ok = res.statusCode == 200 || res.statusCode == 201;

      Map<String, dynamic>? data;
      try {
        data = jsonDecode(res.body) as Map<String, dynamic>;
      } catch (_) {
        data = {'raw': res.body};
      }

      if (ok) {
        return {
          'success': true,
          'data': data,
          'display': 'Đây là bệnh ${data['result']} tình trạng bệnh ${data['getDiseaseSeverity']} hãy cho tôi biết thêm thông tin bệnh và cách chữa',
        };
      } else {
        return {
          'success': false,
          'message': 'HTTP ${res.statusCode}: ${res.reasonPhrase}',
          'data': data,
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Lỗi: $e'};
    }
  }

}
