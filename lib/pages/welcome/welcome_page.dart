import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/viewmodel/user_vm.dart';
import 'package:provider/provider.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  bool _didNavigate = false; // chống navigate lặp

  @override
  void initState() {
    super.initState();
    _bootstrap(); // KHÔNG await trong initState
  }

  Future<void> _bootstrap() async {
    try {
      await context.read<UserVm>().getAllUsers(); // ✅ đợi xong
    } catch (e, s) {
      debugPrint('❌ getAllUsers error: $e\n$s');
      // TODO: showSnackBar / hiển thị lỗi nếu cần
    }

    if (!mounted || _didNavigate) return;
    _didNavigate = true;
    context.goNamed(RouterName.login); // ✅ chỉ chạy sau khi await xong
  }
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Center(
        child: SvgPicture.asset(
          isDark 
          ? 'assets/icons/logo_welcome_dark.svg'
          : 'assets/icons/logo_welcome.svg'
        ),
      ),
    );
  }
}