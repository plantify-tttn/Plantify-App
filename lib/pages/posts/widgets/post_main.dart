import 'package:flutter/material.dart';
import 'package:plantify/theme/color.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class PostMain extends StatelessWidget {
  const PostMain({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Text(
            'Cây tui trồng nè',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500
            ),
          ),
        ),
        Container(
          width: double.infinity,
          height: 260,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcQAC98T2mZJABaQis8ncs--sEMb17f5j6EzMA&s'
              ),
              fit: BoxFit.cover
            )
          ),
        ),
        Row(
          children: [
            statusButton(
              Icon(Icons.favorite, color: Colors.red), 
              123, 
              AppLocalizations.of(context)!.love
            ),
            statusButton(
              Icon(Icons.chat_bubble, color: const Color.fromARGB(255, 159, 217, 173)), 
              123, 
              AppLocalizations.of(context)!.comment
            ),
          ],
        ),
        Container(
          height: 2,
          width: double.infinity,
          color: Color(MyColor.grey),
        ),
        const SizedBox(height: 10,)
      ],
    );
  }
  Widget statusButton(Icon icon, int value, String title){
    return Expanded(
      child: SizedBox(
        height: 40,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 16
              ),
            ),
            icon,
            Text(
              title,
              style: TextStyle(
                fontSize: 16
              ),
            )
          ],
        ),
      ),
    );
  }
}