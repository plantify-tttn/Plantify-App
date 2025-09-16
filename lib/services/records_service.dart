// lib/services/records_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plantify/models/analysis_result.dart';
import 'package:plantify/models/record_model.dart';
import 'package:plantify/models/record_timeline_item.dart';

class RecordsService {
  RecordsService({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;

  String get _base => (dotenv.env['BASE_URL'] ?? '').replaceAll(RegExp(r'/+$'), '');
  Map<String,String> _headers(String t) => {
    'Authorization': 'Bearer $t',
    'Accept': 'application/json',
    'Content-Type': 'application/json',
  };

  Future<List<RecordModel>> fetchAll({required String token}) async {
    final r = await _client.get(Uri.parse('$_base/tracking'), headers: _headers(token));
    if (r.statusCode != 200) { throw Exception('HTTP ${r.statusCode}: ${r.body}'); }
    final body = jsonDecode(r.body);
    final list = body is List ? body : (body['data'] ?? []) as List;
    return list.map< RecordModel >((e) => RecordModel.fromJson(Map<String,dynamic>.from(e))).toList(growable:false);
  }

  Future<RecordModel> create({required String token, required String name, required String image}) async {
    final r = await _client.post(Uri.parse('$_base/tracking'),
      headers: _headers(token),
      body: jsonEncode({'name': name, 'image': image, 'history': []}),
    );
    if (r.statusCode != 200 && r.statusCode != 201) { throw Exception('HTTP ${r.statusCode}: ${r.body}'); }
    final body = jsonDecode(r.body);
    final data = (body is Map && body['data'] != null) ? body['data'] : body;
    return RecordModel.fromJson(Map<String,dynamic>.from(data));
  }

  /// POST /tracking/{id}  { "history": ["<historyId>", ...] }
  Future<void> attachHistory({
    required String token,
    required String recordId,
    required List<String> historyIds,
  }) async {
    final url = Uri.parse('$_base/tracking/$recordId');
    final res = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'history': historyIds}),
    );
    if (res.statusCode < 200 || res.statusCode >= 300) {
      throw Exception('Attach history failed: ${res.statusCode} ${res.body}');
    }
  }

  Future<List<RecordTimelineItem>> fetchTimeline({
    required String token,
    required String recordId,
  }) async {
    final url = Uri.parse('$_base/tracking/$recordId');
    final res = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('fetchTimeline ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is! List) return const [];
    final list = body
        .whereType<Map<String, dynamic>>()
        .map((e) => RecordTimelineItem.fromJson(e))
        .toList();

    // mới nhất trước
    list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list;
  }

  Future<AnalysisResult> analyzeRecord({
    required String token,
    required String recordId,
  }) async {
    final url = Uri.parse('$_base/chatbot/analyze/$recordId');
    final res = await http.post(url, headers: {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    });
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw Exception('analyzeRecord ${res.statusCode}: ${res.body}');
    }
    final body = jsonDecode(res.body);
    if (body is! Map<String, dynamic>) {
      throw Exception('Invalid analyze payload');
    }
    return AnalysisResult.fromJson(body);
  }
}
