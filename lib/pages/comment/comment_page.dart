import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/models/comment_model.dart';
import 'package:plantify/services/comment_service.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/models/user_model.dart';

class CommentPage extends StatefulWidget {
  final PostModel post;
  const CommentPage({super.key, required this.post});

  @override
  State<CommentPage> createState() => _CommentPageState();
}

class _CommentPageState extends State<CommentPage> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<CommentModel>> _commentsFuture;
  late String token;

  // Cache user info để tránh gọi lại nhiều lần
  final Map<String, UserModel?> _userCache = {};

  @override
  void initState() {
    super.initState();
    token = UserService.getToken();
    _loadComments();
  }

  void _loadComments() {
    _commentsFuture = CommentService.getComments(widget.post.id, token);
  }

  Future<void> _addComment() async {
  final text = _controller.text.trim();
  if (text.isNotEmpty) {
    final ok = await CommentService.createComment(
      postId: widget.post.id,
      content: text,
      token: token,
    );

    if (ok) {
      // xoá nội dung TextField
      _controller.clear();

      // gọi lại API để load danh sách mới
      setState(() {
        _loadComments();
      });

      // báo thành công
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Gửi bình luận thành công!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      // báo lỗi
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Gửi bình luận thất bại, thử lại sau.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }
}

  Future<UserModel?> _getUser(String? uid) async {
    if (uid == null) return null;
    if (_userCache.containsKey(uid)) {
      return _userCache[uid];
    }
    // Kiểm tra cache Hive trước
    final cached = UserService.hiveGetUserById(uid);
    if (cached != null) {
      _userCache[uid] = cached;
      return cached;
    }
    try {
      final user = await UserService().getUserById(uid);
      _userCache[uid] = user;
      return user;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bình luận'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(widget.post.content, style: const TextStyle(fontSize: 18)),
          ),
          const Divider(),
          Expanded(
            child: FutureBuilder<List<CommentModel>>(
              future: _commentsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                 // print('❌ Lỗi FutureBuilder: ${snapshot.error}');
                  return const Center(child: Text('Lỗi khi tải bình luận.'));
                }
                final comments = snapshot.data ?? [];
                if (comments.isEmpty) {
                  return const Center(child: Text('Chưa có bình luận nào.'));
                }
                return ListView.builder(
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return FutureBuilder<UserModel?>(
                      future: _getUser(comment.uid.toString()),
                      builder: (context, userSnapshot) {
                        final user = userSnapshot.data;
                        return ListTile(
                          leading: user?.imageUrl != null && user!.imageUrl.isNotEmpty
                              ? CircleAvatar(backgroundImage: NetworkImage(user.imageUrl))
                              : const CircleAvatar(child: Icon(Icons.person)),
                          title: Text(comment.content, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 17)),
                          subtitle: Text(user?.name ?? 'Không rõ', style: const TextStyle(fontSize: 14)),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Nhập bình luận...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addComment,
                  child: const Text('Gửi'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}