import 'package:flutter/material.dart';
import 'package:plantify/pages/home/home_header.dart';
import 'package:plantify/pages/posts/post_layout.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 42,),
          HomeHeader(),
          const SizedBox( height: 20,),
          PostLayout(),
          PostLayout(),
          PostLayout(),
        ],
      ),
    );
  }
}