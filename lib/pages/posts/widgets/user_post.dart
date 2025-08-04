import 'package:flutter/material.dart';

class UserPost extends StatelessWidget {
  const UserPost({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(
              'https://maunaildep.com/wp-content/uploads/2025/04/hinh-anh-trai-dep-2k9-cute-full-hd.jpg'
            ),
            radius: 20,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 8,),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Phương Nguyễn',
                style: TextStyle(
                  fontSize: 16,
                  height: 1,
                  fontWeight: FontWeight.bold
                ),
              ),
              Text(
                '8g',
                style: TextStyle(
                  fontSize: 14,
                  height: 1
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}