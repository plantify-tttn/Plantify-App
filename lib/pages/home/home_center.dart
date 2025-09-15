import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:plantify/pages/diagnose/diagnose_page.dart';
import 'package:plantify/pages/home/home_page.dart';
import 'package:plantify/pages/identify/identify_page.dart';
import 'package:plantify/pages/profile/profile_page.dart';
import 'package:plantify/pages/records/records_page.dart';

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
    RecordsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 👇 màu nền sẽ xuất hiện dưới status bar (vì status bar trong suốt) // hoặc Theme.of(context).scaffoldBackgroundColor
      extendBody: true,
      body: SafeArea(              // ✅ bọc body, không bọc Scaffold
        top: true,
        bottom: false,            // để bar dưới có thể tràn, ta bọc riêng ở dưới
        child: IndexedStack(
          index: _selectedIndex,
          children: _pages,
        ),
      ),

      bottomNavigationBar: SafeArea( // ✅ chỉ đẩy thanh nav lên khỏi system navbar
        top: false,
        child: CurvedNavigationBar(
          index: _selectedIndex,
          height: 60,
          backgroundColor: Colors.transparent,
          color: const Color.fromARGB(255, 110, 135, 112),
          buttonBackgroundColor: const Color.fromARGB(255, 57, 173, 61),
          animationDuration: const Duration(milliseconds: 300),
          animationCurve: Curves.easeInOut,
          items: const [
            // dùng const Image.asset nếu có thể để tối ưu
            Image(image: AssetImage('assets/images/home2.png'), width: 30, height: 30),
            Image(image: AssetImage('assets/images/diagnose2.png'), width: 30, height: 30),
            Image(image: AssetImage('assets/images/identify2.png'), width: 30, height: 30),
            Image(image: AssetImage('assets/images/records2.png'), width: 30, height: 30),
            Image(image: AssetImage('assets/images/profile2.png'), width: 30, height: 30),
          ],
          onTap: (index) => setState(() => _selectedIndex = index),
        ),
      ),
    );
  }
}
