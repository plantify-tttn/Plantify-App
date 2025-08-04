import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:plantify/theme/color.dart';

class GoogleSignin extends StatelessWidget {
  const GoogleSignin({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      height: 37,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Color(MyColor.white),
        border: Border.all(
          width: 1,
          color: Color(MyColor.pr2)
        )
      ),
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Google',
              style: TextStyle(
                fontSize: 15,
                color: Color(MyColor.pr2),
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(width: 5,),
            SvgPicture.asset(
              'assets/icons/google_icon.svg',
              width: 25,
            )
          ],
        ),
      ),
    );
  }
}