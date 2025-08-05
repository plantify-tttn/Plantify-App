import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plantify/widgets/button/search_button.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 0,),
        SvgPicture.asset(
          isDark 
            ? 'assets/icons/logo_home_dark.svg'
            : 'assets/icons/logo_home.svg'
        ),
        SearchButton(),
      ],
    );
  }
}