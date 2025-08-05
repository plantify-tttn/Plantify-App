import 'package:hive/hive.dart';

part 'post_model.g.dart';

@HiveType(typeId: 2)
class PostModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String uid;

  @HiveField(2)
  final String content;

  @HiveField(3)
  final String imageUrl;

  @HiveField(4)
  final int loveCount;

  @HiveField(5)
  final int commentCount;

  @HiveField(6)
  final String createAt;

  PostModel({
    required this.id,
    required this.uid,
    required this.content,
    required this.imageUrl,
    required this.loveCount,
    required this.commentCount,
    required this.createAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'],
      uid: json['uid'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      loveCount: json['loveCount'],
      commentCount: json['commentCount'],
      createAt: json['createAt'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': uid,
      'content': content,
      'imageUrl': imageUrl,
      'loveCount': loveCount,
      'commentCount': commentCount,
      'createAt': createAt,
    };
  }
}
