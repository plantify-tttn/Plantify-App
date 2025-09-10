import 'dart:convert';

class HistoryModel {
  final String id;
  final int userId;
  final String detectType;
  final String label;        // ⬅️ dùng để chứa "id" bên trong result
  final DateTime createdAt;
  final String imageUrl;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.detectType,
    required this.label,     // ⬅️ = result.id
    required this.createdAt,
    required this.imageUrl,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    final resultRaw = json['result'];
    String onlyId = "";

    if (resultRaw != null) {
      try {
        final decoded = resultRaw is String ? jsonDecode(resultRaw) : resultRaw;

        if (decoded is Map<String, dynamic>) {
          // Ưu tiên lấy 'id'
          final dynamic rid = decoded['id'];
          if (rid != null && rid.toString().isNotEmpty) {
            onlyId = rid.toString();
          } else {
            // Fallback: nếu BE cũ không có id, lấy labels.first
            final labels = (decoded['labels'] as List?)?.cast<String>() ?? const [];
            if (labels.isNotEmpty) onlyId = labels.first;
          }
        } else if (decoded is String) {
          // Trường hợp BE gửi thẳng id (không phải JSON)
          onlyId = decoded;
        }
      } catch (_) {
        // Nếu result là chuỗi id thuần (không phải JSON)
        if (resultRaw is String && resultRaw.isNotEmpty) {
          onlyId = resultRaw;
        }
      }
    }

    return HistoryModel(
      id: (json['id'] ?? '').toString(),
      userId: json['userid'] is int ? json['userid'] as int : int.tryParse('${json['userid']}') ?? 0,
      detectType: (json['detect_type'] ?? '').toString(),
      label: onlyId, // ⬅️ giờ label chính là id bên trong result
      createdAt: _parseDt(json['created_at']),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userId,
      'detect_type': detectType,
      // ⬇️ chỉ ghi mỗi id vào result (giữ dạng JSON string cho tương thích)
      'result': jsonEncode({'id': label}),
      'created_at': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

DateTime _parseDt(dynamic v) {
  if (v is String && v.isNotEmpty) {
    // "2025-09-10T17:27:56.529"
    return DateTime.parse(v);
  }
  if (v is int) {
    return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
  }
  return DateTime.now();
}
