import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:plantify/pages/diagnose/diagnose_page.dart';
import 'package:plantify/pages/home/home_page.dart';
import 'package:plantify/pages/identify/identify_page.dart';
import 'package:plantify/pages/profile/profile_page.dart';
import 'package:plantify/pages/records/records_page.dart';

class HomeCenter extends StatefulWidget {
  const HomeCenter({super.key});

  @override
  State<HomeCenter> createState() => _HomeCenterState();
}

class _HomeCenterState extends State<HomeCenter> {
  int _selectedIndex = 0;

  final List<Widget> _pages = <Widget>[
    const HomePage(),
    const DiagnosePage(),
    const IdentifyPage(),
    const RecordsPage(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      // 👇 chỉ hiển thị page hiện tại
      body: SafeArea(
        top: true,
        bottom: false,
        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: SafeArea(
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
