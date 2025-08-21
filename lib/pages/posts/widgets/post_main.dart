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
  String token = '';

  @override
  void initState() {
    super.initState();
    loveCount = widget.post.loveCount;
    _initLoveStatus();
  }

  Future<void> _initLoveStatus() async {
    try {
      token = UserService.getToken();

      final List<String> favorites = await FavoriteService.getFavorites(token);

      setState(() {
        isLoved = favorites.contains(widget.post.id);
      });
    } catch (e) {
      //print('❌ Lỗi khi tải trạng thái love: $e');
    }
  }

  Future<void> toggleLove() async {
    try {
      if (isLoved) {
        final success = await FavoriteService.removeFavorite(widget.post.id, token);
        if (success) {
          setState(() {
            isLoved = false;
            loveCount--;
          });
        }
      } else {
        final success = await FavoriteService.addFavorite(widget.post.id, token);
        if (success) {
          setState(() {
            isLoved = true;
            loveCount++;
          });
        }
      }
    } catch (e) {
      //print("❌ Lỗi khi toggle love: $e");
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
                onTap: toggleLove,
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
                onTap: () {
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => CommentPage(post: widget.post))
                  );
                },
                child: statusButton(
                  const Icon(Icons.chat_bubble, color: Color.fromARGB(255, 159, 217, 173)),
                  widget.post.commentCount,
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
