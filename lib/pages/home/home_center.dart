import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:plantify/pages/diagnose/diagnose_page.dart';
import 'package:plantify/pages/home/home_page.dart';
import 'package:plantify/pages/identify/identify_page.dart';
import 'package:plantify/pages/profile/profile_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeCenter extends StatefulWidget {
  const HomeCenter({super.key,});

  @override
  State<HomeCenter> createState() => _HomeCenterState();
}

class _HomeCenterState extends State<HomeCenter> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    HomePage(),
    DiagnosePage(),
    IdentifyPage(),
    ProfilePage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  void refreshMiniPlayer() {
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          IndexedStack(
            index: _selectedIndex,
            children: _pages,
          ),
        ],
      ),
      extendBody: true,
      bottomNavigationBar: CurvedNavigationBar(
      index: _selectedIndex,
      height: 60,
      backgroundColor: Colors.transparent, // 👈 để thấy nội dung phía dưới
      color: Colors.green.shade700, // màu của thanh cong
      buttonBackgroundColor: Colors.green, // màu nút nổi
      animationDuration: const Duration(milliseconds: 300),
      animationCurve: Curves.easeInOut,
      items: <Widget>[
        Image.asset('assets/images/home2.png', width: 30, height: 30),
        Image.asset('assets/images/diagnose2.png', width: 30, height: 30),
        Image.asset('assets/images/identify2.png', width: 30, height: 30),
        Image.asset('assets/images/profile2.png', width: 30, height: 30),
      ],
      onTap: (index) {
        setState(() {
          _selectedIndex = index;
        });
      },
    ),
    );
  }
}