class FavoriteModel {
  final String postId;

  FavoriteModel({required this.postId});

  factory FavoriteModel.fromJson(Map<String, dynamic> json) {
    return FavoriteModel(postId: json['postId']);
  }

  Map<String, dynamic> toJson() => {
        'postId': postId,
      };
}
