class PostModel {
  final String id;
  final String uid;
  final String content;
  final String imageUrl;
  final int loveCount;
  final int commentCount;
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
      'uid': uid,
      'content': content,
      'imageUrl': imageUrl,
      'createAt': createAt,
    };
  }
}
