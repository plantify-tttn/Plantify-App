import 'package:flutter/material.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/theme/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingPage extends StatelessWidget {
  const SettingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final localeProvider = Provider.of<LocaleProvider>(context);
    final local = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(local.setting),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showLanguageDialog(context, localeProvider),
              icon: const Icon(Icons.language),
              label: Text(local.changeLanguage),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => themeProvider.toggleTheme(),
              icon: Icon(themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode),
              label: Text(local.changeTheme),
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
