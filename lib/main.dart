import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plantify/hive_initializer.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/pages/my_app.dart';
import 'package:plantify/viewmodel/user_vm.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await initHive();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 👈 Trong suốt
      statusBarIconBrightness: Brightness.dark, // icon đen (nếu nền sáng)
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserVm()),
      ],
      child: const MyApp(),
    ),
  );
}
