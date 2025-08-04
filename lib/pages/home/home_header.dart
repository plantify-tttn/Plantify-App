import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const SizedBox(width: 0,),
        SvgPicture.asset(
          'assets/icons/logo_home.svg'
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 35),
          margin: EdgeInsets.symmetric(horizontal: 30),
          height: 35,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Color(MyColor.pr2),
            ),
            borderRadius: BorderRadius.circular(20)
          ),
          child: Row(
            children: [
              Icon(Icons.search_sharp, color: Color(MyColor.grey),),
              const SizedBox(width: 5,),
              Text(
                AppLocalizations.of(context)!.searchplants,
                style: TextStyle(
                  color: Color(MyColor.grey)
                ),
              )
            ],
          ),
        )
      ],
    );
  }
}