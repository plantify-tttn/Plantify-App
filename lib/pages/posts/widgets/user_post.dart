import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/models/user_model.dart';
import 'package:plantify/services/user_service.dart';
import 'package:intl/intl.dart'; // để format thời gian

class UserPost extends StatelessWidget {
  final PostModel post;

  const UserPost({
    super.key,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: UserService().getUserById(post.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [CircularProgressIndicator()]),
          );
        } else if (snapshot.hasError) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 15),
            child: Row(children: [Text("Lỗi khi tải user")]),
          );
        } else if (!snapshot.hasData) {
          return const SizedBox();
        }

        final user = snapshot.data!;
        final formattedTime = _formatTime(post.createAt);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.grey[200],
                child: ClipOval(
                  child: Image.network(
                    user.imageUrl,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 24);
                    },
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    formattedTime,
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  /// Format chuỗi thời gian ISO thành "HH:mm dd/MM/yyyy"
  String _formatTime(String isoTime) {
    try {
      final dateTime = DateTime.parse(isoTime);
      return DateFormat('HH:mm dd/MM/yyyy').format(dateTime);
    } catch (_) {
      return isoTime;
    }
  }
}
