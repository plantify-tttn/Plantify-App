import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:plantify/apps/router/router_name.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SearchButton extends StatelessWidget {
  const SearchButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.goNamed(RouterName.search);
      },
      child: Container(
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
      ),
    );
  }
}