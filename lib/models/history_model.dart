import 'dart:convert';
import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 12)
class HistoryModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int userId;

  @HiveField(2)
  final String detectType;

  /// label = result.id (đã “rút gọn” khi parse)
  @HiveField(3)
  final String label;

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String imageUrl;

  HistoryModel({
    required this.id,
    required this.userId,
    required this.detectType,
    required this.label,
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
          final dynamic rid = decoded['id'];
          if (rid != null && rid.toString().isNotEmpty) {
            onlyId = rid.toString();
          } else {
            final labels = (decoded['labels'] as List?)?.cast<String>() ?? const [];
            if (labels.isNotEmpty) onlyId = labels.first;
          }
        } else if (decoded is String) {
          onlyId = decoded;
        }
      } catch (_) {
        if (resultRaw is String && resultRaw.isNotEmpty) {
          onlyId = resultRaw;
        }
      }
    }

    return HistoryModel(
      id: (json['id'] ?? '').toString(),
      userId: json['userid'] is int ? json['userid'] as int : int.tryParse('${json['userid']}') ?? 0,
      detectType: (json['detect_type'] ?? '').toString(),
      label: onlyId,
      createdAt: _parseDt(json['created_at']),
      imageUrl: (json['imageUrl'] ?? json['image_url'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': userId,
      'detect_type': detectType,
      'result': jsonEncode({'id': label}),
      'created_at': createdAt.toIso8601String(),
      'imageUrl': imageUrl,
    };
  }
}

DateTime _parseDt(dynamic v) {
  if (v is String && v.isNotEmpty) {
    return DateTime.parse(v);
  }
  if (v is int) {
    return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
  }
  return DateTime.now();
}
