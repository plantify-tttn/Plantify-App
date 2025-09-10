import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/services/user_service.dart';
import 'package:plantify/theme/color.dart';
import 'package:plantify/provider/login_vm.dart';
import 'package:plantify/provider/user_vm.dart';
import 'package:plantify/widgets/button/google_signin.dart';
import 'package:plantify/widgets/textfield/login_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Consumer<LoginVm>(
      builder: (context, loginVm, child) {
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
            // appBar: AppBar(
            //   backgroundColor: Colors.transparent,
            //   elevation: 0,
            //   shadowColor: Colors.transparent,
            //   leading: IconButton(
            //     onPressed: () {
            //       context.goNamed(RouterName.home);
            //     },
            //     icon: Icon(Icons.arrow_back_outlined)
            //   ),
            // ),
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
                  child: Column(
                    children: [
                      const SizedBox(height: 150), // Khoảng cách từ trên xuống
                      Text(
                        AppLocalizations.of(context)!.login,
                        style: TextStyle(
                          fontSize: 33,
                          fontWeight: FontWeight.bold,
                          color: Color(MyColor.pr2),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: LoginTextfield(
                          controller: loginVm.emailController,
                          onChanged: (_) => loginVm.updateCan(),
                          hintText: "Email",
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 35,
                          vertical: 10,
                        ),
                        child: LoginTextfield(
                          controller: loginVm.passController,
                          onChanged: (_) => loginVm.updateCan(),
                          hintText: "Mật Khẩu",
                          isPassword: true,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 28),
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Text('Quên mật khẩu?'),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Bạn Chưa có tài khoản?',
                            style: TextStyle(
                              color: Color(MyColor.black),
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(width: 20),
                          GestureDetector(
                            onTap: () {
                              context.goNamed(RouterName.register);
                            },
                            child: Text(
                              'Đăng ký',
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
                          if (!loginVm.canLogin) return;

                          final ok = await loginVm.login();
                          if (!context.mounted) return;

                          if (ok == 'ok') {
                            final saved =
                                UserService.hiveGetUser(); // lấy user vừa lưu
                            if (saved != null) {
                              await context
                                  .read<UserVm>()
                                  .loadUser(saved.id, forceRefresh: true);
                            }
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('✅ Đăng nhập thành công')),
                            );
                            context.goNamed(RouterName.home);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Tài khoản hoặc mật khẩu không dúng")),
                            );
                          }
                        },
                        child: Container(
                          width: 160,
                          height: 37,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: loginVm.canLogin
                                ? Color(MyColor.pr2)
                                : Color(MyColor.grey),
                          ),
                          child: Center(
                            child: Text(
                              'Đăng nhập',
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
                      const SizedBox(height: 70),
                      SvgPicture.asset(isDark
                          ? 'assets/icons/logo_welcome_dark.svg'
                          : 'assets/icons/logo_welcome.svg'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
