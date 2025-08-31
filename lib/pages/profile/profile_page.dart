import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/pages/profile/user_post_page.dart';
import 'package:plantify/pages/profile/user_profile_page.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/theme/color.dart';
import 'package:plantify/theme/theme_provider.dart';
import 'package:plantify/provider/user_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.profile),
      ),
      body:
          _buildUserInfo(context),
    );
  }

  Widget _buildUserInfo(BuildContext context) {
  final user = context.watch<UserVm>().user; // 👈 listen changes từ Hive qua UserVm
  final themeProvider = Provider.of<ThemeProvider>(context);
  final localeProvider = Provider.of<LocaleProvider>(context);
  final local = AppLocalizations.of(context)!;

  if (user == null) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.info_outline, size: 50, color: Colors.grey),
          const SizedBox(height: 12),
          const Text("Chưa có thông tin người dùng"),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            icon: const Icon(Icons.logout),
            label: Text(AppLocalizations.of(context)!.login),
            onPressed: () => context.goNamed(RouterName.login),
          ),
        ],
      ),
    );
  }

  return SingleChildScrollView(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 40),
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(user.imageUrl),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            user.name,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            user.email,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          // 📌 Nút OutlinedButton: Thông tin cá nhân
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.person_outline, color: Colors.blue),
              label: const Text(
                "Thông tin cá nhân",
                style: TextStyle(color: Colors.blue),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserProfilePage()),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 📌 Nút OutlinedButton: Bài viết
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.article_outlined, color: Colors.green),
              label: const Text(
                "Bài viết",
                style: TextStyle(color: Colors.green),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.green, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const UserPostPage()),
                );
              },
            ),
          ),
          const SizedBox(height: 10),

          // 🌐 Nút OutlinedButton: Đổi ngôn ngữ
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.language, color: Colors.orange),
              label: Text(
                local.changeLanguage,
                style: const TextStyle(color: Colors.orange),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.orange, width: 1.2),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => _showLanguageDialog(context, localeProvider),
            ),
          ),
          const SizedBox(height: 10),

          // 🎨 Nút OutlinedButton: Đổi theme
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                color: themeProvider.isDarkMode ? Colors.tealAccent : Colors.indigo,
              ),
              label: Text(
                local.changeTheme,
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.tealAccent : Colors.indigo,
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: themeProvider.isDarkMode ? Colors.tealAccent : Colors.indigo,
                  width: 1.2,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => themeProvider.toggleTheme(),
            ),
          ),
          const SizedBox(height: 24),

          // 🔴 Đăng xuất
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.logout),
              label: Text(local.logout),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                textStyle: const TextStyle(fontSize: 16),
              ),
              onPressed: () async {
                final local = AppLocalizations.of(context)!;
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(local.logoutConfirmTitle),
                    content: Text(local.logoutConfirmContent),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(local.cancel, style: TextStyle(
                          color: Color(MyColor.pr2)
                        ),),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: Text(local.logout, style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold
                        ),),
                      ),
                    ],
                  ),
                );
                // Sửa lỗi dùng context sau async gap
                if (confirm == true) {
                  if (context.mounted) {
                    context.goNamed(RouterName.login);
                    context.read<UserVm>().logout();
                  }
                }
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) {
    final currentLocale = localeProvider.locale;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              trailing: currentLocale.languageCode == 'en'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              tileColor: currentLocale.languageCode == 'en'
                  ? Colors.blue[100]
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Tiếng Việt'),
              trailing: currentLocale.languageCode == 'vi'
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              tileColor: currentLocale.languageCode == 'vi'
                  ? Colors.blue[100]
                  : null,
              onTap: () {
                localeProvider.setLocale(const Locale('vi'));
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

}
