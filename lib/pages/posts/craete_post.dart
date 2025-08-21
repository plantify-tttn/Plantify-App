import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/services/user_service.dart';

class CraetePost extends StatelessWidget {
  const CraetePost({super.key});

  @override
  Widget build(BuildContext context) {
    final user = UserService.hiveGetUser();
    print('====${user!.imageUrl}');
    return GestureDetector(
      onTap: () {
        context.goNamed(RouterName.createPost);
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).brightness == Brightness.dark 
              ? Colors.white24
              : Colors.black26,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(
                user.imageUrl, // Replace with actual user avatar URL
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.createPostHint,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                )
              ),
            ),   
          ],
        ),
      ),
    );
  }
}