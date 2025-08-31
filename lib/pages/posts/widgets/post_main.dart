import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/pages/comment/comment_page.dart';
import 'package:plantify/services/favorite_service.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostMain extends StatefulWidget {
  final PostModel post;
  const PostMain({super.key, required this.post});

  @override
  State<PostMain> createState() => _PostMainState();
}

class _PostMainState extends State<PostMain> {
  bool isLoved = false;
  int loveCount = 0;
  int commentCount = 0;     
  String token = '';
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    loveCount = widget.post.likeCount;
    token = UserService.getToken();
    // tô màu lúc load theo Hive
    isLoved = FavouriteLocal.isLoved(widget.post.id);
    commentCount = widget.post.commentCount;
  }

  Future<void> _toggle() async {
    if (_busy) return;
    setState(() => _busy = true);

    final before = isLoved;
    final after = await FavoriteService.toggleByResponse(widget.post.id, token);

    if (after != null) {
      setState(() {
        isLoved = after;                       // icon color
        if (after != before) {
          loveCount += after ? 1 : -1;         // counter
          if (loveCount < 0) loveCount = 0;
        }
        _busy = false;
      });
    } else {
      // request failed -> không đổi trạng thái
      setState(() => _busy = false);
      // optionally show SnackBar here
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nội dung bài viết
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            widget.post.content,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),

        // Ảnh bài viết
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(widget.post.imageurl),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Các nút tương tác
        Row(
          children: [
            // ❤️ Love
            Expanded(
          child: GestureDetector(
            onTap: _busy ? null : _toggle,
            child: statusButton(
              Icon(
                isLoved ? Icons.favorite : Icons.favorite_border,
                color: isLoved ? Colors.red : Colors.grey,
              ),
              loveCount,
              AppLocalizations.of(context)!.love,
            ),
          ),
        ),


            // 💬 Comment
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  final added = await Navigator.push<int>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CommentPage(post: widget.post),
                  ),
                );
                if (added != null && added > 0 && mounted) {
                  setState(() => commentCount += added); // ✅ update
                }
                },
                child: statusButton(
                  const Icon(Icons.chat_bubble, color: Color.fromARGB(255, 159, 217, 173)),
                  commentCount,
                  AppLocalizations.of(context)!.comment,
                ),
              ),
            ),
          ],
        ),

        // Gạch ngăn
        Container(
          height: 2,
          width: double.infinity,
          color: Color(MyColor.grey),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget statusButton(Icon icon, int value, String title) {
    return SizedBox(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value.toString(),
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(width: 4),
          icon,
          const SizedBox(width: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
