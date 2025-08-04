import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/theme/color.dart';
import 'package:plantify/viewmodel/register_vm.dart';
import 'package:plantify/widgets/button/google_signin.dart';
import 'package:plantify/widgets/textfield/login_textfield.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<RegisterVm>(
      builder: (context, registerVm, child){
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
                onPressed: (){
                  context.goNamed(RouterName.login);
                }, 
                icon: Icon(Icons.arrow_back_outlined)
              ),
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
                          AppLocalizations.of(context)!.login,
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
                            if (registerVm.canRegister == false){
                              return;
                            }
                            await registerVm.register(context);
                            if (!context.mounted) return;
                            context.goNamed(RouterName.login);
                          },
                          child: Container(
                            width: 160,
                            height: 37,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: registerVm.canRegister ? Color(MyColor.pr2) : Color(MyColor.grey),
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
                        SvgPicture.asset('assets/icons/logo_welcome.svg'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}

