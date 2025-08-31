import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/provider/post_provider.dart';
import 'package:plantify/provider/user_vm.dart';
import 'package:plantify/services/user_service.dart';
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
    // Tránh navigate ngay trong initState: schedule sau frame đầu tiên
    WidgetsBinding.instance.addPostFrameCallback((_) => _bootstrap());
  }

  Future<void> _bootstrap() async {
    try {
      // 1) Lấy token mềm từ Hive
      final user = UserService.hiveGetUser();
      final token = user?.accessToken ?? '';
      await context.read<UserVm>().getAllUsers();
      await context.read<PostProvider>().getPosts();

      // 2) Check local exp
      if (token.isEmpty || JwtUtil.isExpired(token)) {
        await UserService.hiveDeleteUser(); // optional
        if (!mounted || _didNavigate) return;
        _didNavigate = true;
        context.goNamed(RouterName.login);
        return;
      }

      // 3) Confirm với server (phòng revoke)
      final ok = await JwtUtil.validateRemote(token);
      if (!ok) {
        await UserService.hiveDeleteUser(); // optional
        if (!mounted || _didNavigate) return;
        _didNavigate = true;
        context.goNamed(RouterName.login);
        return;
      }

      // 5) Điều hướng vào home
      if (!mounted || _didNavigate) return;
      _didNavigate = true;
      context.goNamed(RouterName.home); // hoặc RouterName.homeCenter
    } catch (e, s) {
      debugPrint('❌ bootstrap error: $e\n$s');
      if (!mounted || _didNavigate) return;
      _didNavigate = true;
      context.goNamed(RouterName.login);
    }
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
              : 'assets/icons/logo_welcome.svg',
        ),
      ),
    );
  }
}
