// lib/models/record_timeline_item.dart
class RecordTimelineItem {
  final String id;
  final int userId;
  final String detectType; // 'seed' | 'diseases'
  final DateTime createdAt;
  final String imageUrl;

  // Chỉ có khi detectType == 'diseases'
  final String? diseases;
  final String? severity;

  RecordTimelineItem({
    required this.id,
    required this.userId,
    required this.detectType,
    required this.createdAt,
    required this.imageUrl,
    this.diseases,
    this.severity,
  });

  factory RecordTimelineItem.fromJson(Map<String, dynamic> j) {
    return RecordTimelineItem(
      id: (j['id'] ?? '').toString(),
      userId: j['userid'] is int ? j['userid'] as int : int.tryParse('${j['userid']}') ?? 0,
      detectType: (j['detect_type'] ?? '').toString(),
      createdAt: DateTime.tryParse('${j['created_at']}') ?? DateTime.now(),
      imageUrl: (j['imageUrl'] ?? j['image_url'] ?? '').toString(),
      diseases: j['diseases'] == null ? null : j['diseases'].toString(),
      severity: j['severity'] == null ? null : j['severity'].toString(),
    );
  }
}
