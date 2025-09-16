// lib/models/record_model.dart
import 'package:hive/hive.dart';

part 'record_model.g.dart';

@HiveType(typeId: 14)
class RecordModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String image;

  @HiveField(3)
  final int userId;

  @HiveField(4)
  final DateTime createdAt;

  /// Danh sách ID history thuộc record
  @HiveField(5)
  final List<String> history;

  RecordModel({
    required this.id,
    required this.name,
    required this.image,
    required this.userId,
    required this.createdAt,
    this.history = const [],
  });

  factory RecordModel.fromJson(Map<String, dynamic> j) {
    final raw = j['history'];
    final List<String> hist = (raw is List ? raw : const [])
        .map((e) => e.toString())
        .toList(growable: false);

    return RecordModel(
      id: (j['id'] ?? '').toString(),
      name: (j['name'] ?? '').toString(),
      image: (j['image'] ?? '').toString(),
      userId: j['user_id'] is int
          ? j['user_id'] as int
          : int.tryParse('${j['user_id']}') ?? 0,
      createdAt: _parseDt(j['created_at']),
      history: hist,
    );
  }

  /// Dữ liệu gửi lên API (chỉ ID cho history)
  Map<String, dynamic> toApiJson() => {
        'id': id,
        'name': name,
        'image': image,
        'user_id': userId,
        'created_at': createdAt.toIso8601String(),
        'history': history, // list ID
      };

  RecordModel copyWith({
    String? id,
    String? name,
    String? image,
    int? userId,
    DateTime? createdAt,
    List<String>? history,
  }) =>
      RecordModel(
        id: id ?? this.id,
        name: name ?? this.name,
        image: image ?? this.image,
        userId: userId ?? this.userId,
        createdAt: createdAt ?? this.createdAt,
        history: history ?? this.history,
      );
}

DateTime _parseDt(dynamic v) {
  if (v is String && v.isNotEmpty) return DateTime.parse(v);
  if (v is int) {
    return DateTime.fromMillisecondsSinceEpoch(v, isUtc: true).toLocal();
  }
  return DateTime.now();
}
