import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/theme/color.dart';
import 'package:plantify/provider/register_vm.dart';
import 'package:plantify/widgets/button/google_signin.dart';
import 'package:plantify/widgets/textfield/login_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<RegisterVm>(builder: (context, registerVm, child) {
      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.transparent,
          statusBarColor: Colors.transparent,
          systemNavigationBarIconBrightness: Brightness.dark,
          statusBarIconBrightness: Brightness.dark,
        ),
        child: Scaffold(
          backgroundColor: Colors.transparent, // 👈 Không che gradient
          extendBody: true, // 👈 Cho gradient tràn xuống dưới
          resizeToAvoidBottomInset: false,
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            shadowColor: Colors.transparent,
            leading: IconButton(
                onPressed: () {
                  context.goNamed(RouterName.login);
                },
                icon: Icon(Icons.arrow_back_outlined)),
          ),
          body: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color(MyColor.pr4),
                        Theme.of(context).primaryColor,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [0.0, 0.22],
                    ),
                  ),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 100), // Khoảng cách từ trên xuống
                      Text(
                        AppLocalizations.of(context)!.register,
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Color(MyColor.pr2),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: LoginTextfield(
                          controller: registerVm.usernameController,
                          onChanged: registerVm.validateUsername,
                          hintText: "Tên tài khoản",
                          errorText: registerVm.usernameError,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: LoginTextfield(
                          controller: registerVm.emailController,
                          onChanged: registerVm.validateEmail,
                          hintText: "Email",
                          errorText: registerVm.emailError,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: LoginTextfield(
                          controller: registerVm.passController,
                          onChanged: registerVm.validatePassword,
                          hintText: "Mật khẩu",
                          errorText: registerVm.passError,
                          isPassword: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: LoginTextfield(
                          controller: registerVm.rePassController,
                          onChanged: registerVm.validateRePassword,
                          hintText: "Xác nhận mật khẩu",
                          errorText: registerVm.rePassError,
                          isPassword: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bạn đã có tài khoản?',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              context.goNamed(RouterName.login);
                            },
                            child: Text(
                              'Đăng nhập',
                              style: TextStyle(
                                color: Color(MyColor.pr2),
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () async {
                          if (!registerVm.canRegister) return;

                          FocusScope.of(context).unfocus();
                          await registerVm.register(context);
                          if (!context.mounted) return;

                          if (registerVm.isRegister) {
                            // SnackBar báo trước (optional nhưng recommend)
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text("Đăng ký thành công"),
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 1),
                              ),
                            );

                            // Confirm dialog “đẹp”
                            final confirm = await showPrettyConfirm(
                              context,
                              title: "Đăng ký thành công 🎉",
                              message:
                                  "Bạn muốn chuyển sang trang đăng nhập không?",
                              confirmText: "Đi đến Login",
                              cancelText: "Ở lại",
                            );

                            if (confirm == true && context.mounted) {
                              context.goNamed(RouterName.login);
                            }
                          }
                        },
                        child: Container(
                          width: 160,
                          height: 37,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: registerVm.canRegister
                                ? Color(MyColor.pr2)
                                : Color(MyColor.grey),
                          ),
                          child: Center(
                            child: Text(
                              'Đăng ký',
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(MyColor.white),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      GoogleSignin(),
                      const SizedBox(height: 25),
                      SvgPicture.asset(isDark
                          ? 'assets/icons/logo_welcome_dark.svg'
                          : 'assets/icons/logo_welcome.svg'),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

Future<bool?> showPrettyConfirm(
  BuildContext context, {
  String title = "Đăng ký thành công 🎉",
  String message = "Bạn có muốn chuyển sang trang đăng nhập không?",
  String confirmText = "Chuyển đến Login",
  String cancelText = "Ở lại",
}) {
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return showDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black.withOpacity(0.35), // dim background
    builder: (ctx) {
      return Center(
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOutBack,
          builder: (_, scale, child) =>
              Transform.scale(scale: scale, child: child),
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withOpacity(0.05)
                        : Colors.white.withOpacity(0.75),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withOpacity(0.12)
                          : Colors.black.withOpacity(0.06),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Icon badge
                      Container(
                        height: 56,
                        width: 56,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withOpacity(0.95),
                              theme.colorScheme.secondary.withOpacity(0.95),
                            ],
                          ),
                        ),
                        child: const Icon(Icons.check_rounded,
                            color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 14),

                      // Title
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Message
                      Text(
                        message,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Buttons row
                      Row(
                        children: [
                          // Cancel - ghost button
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () {
                                HapticFeedback.selectionClick();
                                Navigator.of(ctx).pop(false);
                              },
                              style: OutlinedButton.styleFrom(
                                foregroundColor:
                                    isDark ? Colors.white70 : Colors.black87,
                                side: BorderSide(
                                  color: isDark
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.black.withOpacity(0.12),
                                ),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: Text(cancelText),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Confirm - gradient pill
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                HapticFeedback.lightImpact();
                                Navigator.of(ctx).pop(true);
                              },
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                padding: EdgeInsets.zero,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                backgroundColor: Colors.transparent,
                              ),
                              child: Ink(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      theme.colorScheme.primary,
                                      theme.colorScheme.secondary,
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: Container(
                                  alignment: Alignment.center,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                  child: Text(
                                    confirmText,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}
