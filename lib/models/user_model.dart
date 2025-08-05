class UserModel {
  final String id;
  final String name;
  final String imageUrl;
  final String email;

  UserModel({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.email,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'].toString(),           // ✅ ép về String để tránh lỗi nếu backend trả int
      name: json['name'] ?? 'No name',     // ✅ thêm fallback tránh null
      imageUrl: json['imageUrl'] ?? '',    // ✅ tránh null
      email: json['email'] ?? '',
    );
  }
  Map<String, dynamic> toJson(){
    return {
      "name": name,
      "imageUrl": imageUrl,
      "email": email
    };
  }
}
