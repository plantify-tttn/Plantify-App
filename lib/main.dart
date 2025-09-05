import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:plantify/hive_initializer.dart';
import 'package:plantify/l10n/locale_provider.dart';
import 'package:plantify/pages/my_app.dart';
import 'package:plantify/provider/diagnose_provider.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:plantify/provider/search_vm.dart';
import 'package:plantify/provider/user_vm.dart';
import 'package:provider/provider.dart';
import 'theme/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  await dotenv.load(fileName: ".env");
  await initHive();
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // status bar trong suốt
      systemNavigationBarColor: Colors.transparent, // navigation bar trong suốt
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => UserVm()..init(), lazy: false,),
        ChangeNotifierProvider(create: (_) => PostProvider()),
        ChangeNotifierProvider(create: (_) => DiagnoseProvider()),
        ChangeNotifierProvider(create: (_) => SearchVm())
      ],
      child: const MyApp(),
    ),
  );
}
