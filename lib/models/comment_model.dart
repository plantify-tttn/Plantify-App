import 'package:hive/hive.dart';

part 'comment_model.g.dart';


@HiveType(typeId: 4)
class CommentModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final int uid;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final DateTime createdAt;

  CommentModel({
    required this.id,
    required this.uid,
    required this.content,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> json) {
    return CommentModel(
      id: json['id'],
      uid: json['userid'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userid': uid,
      'content': content,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
