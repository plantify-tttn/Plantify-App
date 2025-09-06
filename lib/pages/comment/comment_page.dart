import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/models/comment_model.dart';
import 'package:plantify/services/comment_service.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/models/user_model.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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

  final Map<String, UserModel?> _userCache = {};
  int _addedCount = 0; // ✅ đếm số comment mới
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    token = UserService.getToken();
    _loadComments();
  }

  void _loadComments() {
    _commentsFuture = CommentService.getComments(widget.post.id, token);
  }

  Future<UserModel?> _getUser(String? uid) async {
    if (uid == null || uid.isEmpty) return null;
    if (_userCache.containsKey(uid)) return _userCache[uid];

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

  Future<void> _addComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() => _sending = true);
    final ok = await CommentService.createComment(
      postId: widget.post.id,
      content: text,
      token: token,
    );

    if (!mounted) return;
    if (ok) {
      _controller.clear();
      FocusScope.of(context).unfocus(); // đóng bàn phím
      _addedCount++;
      setState(_loadComments); // reload list
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Gửi bình luận thành công!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('❌ Gửi bình luận thất bại')),
      );
    }
    setState(() => _sending = false);
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    return WillPopScope(
      // ✅ trả result khi back (swipe/back)
      onWillPop: () async {
        Navigator.pop(context, _addedCount);
        return false;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              local.comment
            ),
            leading: IconButton(
              // ✅ back button cũng trả result
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context, _addedCount),
            ),
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(widget.post.content,
                    style: const TextStyle(fontSize: 18)),
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
                      return Center(child: Text(local.errUpload));
                    }
                    final comments = snapshot.data ?? [];
                    if (comments.isEmpty) {
                      return Center(child: Text(local.noComment));
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
                              leading: user?.imageUrl != null &&
                                      user!.imageUrl.isNotEmpty
                                  ? CircleAvatar(
                                      backgroundImage:
                                          NetworkImage(user.imageUrl))
                                  : const CircleAvatar(child: Icon(Icons.person)),
                              title: Text(comment.content,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w500, fontSize: 17)),
                              subtitle: Text(user?.name ?? local.unKnow,
                                  style: const TextStyle(fontSize: 14)),
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
                        decoration: InputDecoration(
                          hintText: local.enterComment,
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
        ),
      ),
    );
  }
}
