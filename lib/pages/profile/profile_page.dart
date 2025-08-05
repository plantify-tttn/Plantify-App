import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/theme/theme_provider.dart';
import 'package:plantify/viewmodel/user_vm.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userVm = Provider.of<UserVm>(context);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.profile),
      ),
      body:
          _buildUserInfo(context, userVm),
    );
  }

  Widget _buildUserInfo(BuildContext context, UserVm userVm) {
  final user = UserService.hiveGetUser();
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

          // 🌐 Đổi ngôn ngữ
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.language),
              label: Text(local.changeLanguage),
              onPressed: () {
                _showLanguageDialog(context, localeProvider);
              },
            ),
          ),
          const SizedBox(height: 12),

          // 🎨 Đổi theme
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: Icon(
                themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
              ),
              label: Text(local.changeTheme),
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
              onPressed: () {
                userVm.logout();
                context.goNamed(RouterName.login);
              },
            ),
          ),
        ],
      ),
    ),
  );
}

  void _showLanguageDialog(BuildContext context, LocaleProvider localeProvider) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.chooseLanguage),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              onTap: () {
                localeProvider.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Tiếng Việt'),
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
