import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/provider/user_vm.dart';
import 'package:provider/provider.dart';

class CreatePost extends StatelessWidget { // 👈 rename: CreatePost
  const CreatePost({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<UserVm>().user; // 👈 auto-rebuild when Hive changes

    // Null-safe: nếu chưa login / chưa có user
    final placeholderUrl = 'https://cdn-icons-png.flaticon.com/512/8792/8792047.png';
    final raw = user?.imageUrl ?? '';
    final avatarUrl = (raw.isNotEmpty && raw.startsWith('http'))
        ? '$raw${raw.contains('?') ? '&' : '?'}ts=${DateTime.now().millisecondsSinceEpoch}' // cache-bust
        : (raw.isNotEmpty ? raw : placeholderUrl);

    return GestureDetector(
      onTap: () => context.goNamed(RouterName.createPost),
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
              backgroundImage: NetworkImage(avatarUrl),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                AppLocalizations.of(context)!.createPostHint,
                style: const TextStyle(color: Colors.grey, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
