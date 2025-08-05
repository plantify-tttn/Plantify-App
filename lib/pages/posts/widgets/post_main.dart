import 'package:flutter/material.dart';
import 'package:plantify/models/post_model.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostMain extends StatelessWidget {
  final PostModel post;
  const PostMain({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            post.content,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                post.imageUrl
              ),
              fit: BoxFit.cover
            )
          ),
        ),
        Row(
          children: [
            statusButton(
              Icon(Icons.favorite, color: Colors.red), 
              post.loveCount, 
              AppLocalizations.of(context)!.love
            ),
            statusButton(
              Icon(Icons.chat_bubble, color: const Color.fromARGB(255, 159, 217, 173)), 
              post.commentCount, 
              AppLocalizations.of(context)!.comment
            ),
          ],
        ),
        Container(
          height: 2,
          width: double.infinity,
          color: Color(MyColor.grey),
        ),
        const SizedBox(height: 10,)
      ],
    );
  }
  Widget statusButton(Icon icon, int value, String title){
    return Expanded(
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16
              ),
            ),
            icon,
            Text(
              title,
              style: TextStyle(
                fontSize: 16
              ),
            )
          ],
        ),
      ),
    );
  }
}